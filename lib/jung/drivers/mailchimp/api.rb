class Jung::Drivers::Mailchimp::Api

  attr_reader :gb, :list_id, :errors
  attr_writer :errors

  def initialize(config)
    @gb = Gibbon.new config.options["api_key"]
    @list_id = config.options["list_id"]
  end

  # List Related

  def list_merge_var_add(merge_var)
    tag = merge_var.to_s.upcase
    name = tag.capitalize

    @merge_vars ||= list_merge_vars

    return true unless !@merge_vars.include? tag

    # Cache is never ugly
    @merge_vars << tag

    gb.list_merge_var_add({
      :id => list_id,
      :tag => tag,
      :name => name
    })
  end

  def list_merge_vars
    merge_vars_array = gb.list_merge_vars :id => list_id
    merge_vars_array.map { |e| e["tag"] }
  end

  def list_subscribe(recipient)  
    merge_vars = recipient.custom_fields.reduce({"FNAME" => recipient.name }) do | acc, v |
      acc[v.first.to_s.upcase] = v.last
      acc
    end if recipient.custom_fields != nil
  
    add_errors_and_return(gb.list_subscribe({
      :id => list_id,
      :email_address => recipient.address,
      :merge_vars => merge_vars,
      :double_optin => false,
      :update_existin => true
    })) { self == true }
  end

  def list_unsubscribe(address)
    gb.list_unsubscribe({
      :id => list_id,
      :email_address => address,
      :delete_member => false,
      :send_goodbye => false
    })
  end

  def list_members
    current_members = []
    members_array = gb.list_members :id => list_id, :limit => 15000
    members_array["data"].each do |member|
      # TODO: Batch this method (Mailchimp supports up to 50 per call)
      info = gb.list_member_info :id => list_id, :email_address => member["email"]
      current_members << Jung::Recipient.new({
        :name => info["data"][0]["merges"]["FNAME"],
        :address => member["email"],
        :custom_fields => info["data"][0]["merges"]
      })
    end
    current_members
  end

  def list_static_segments
    gb.list_static_segments(:id => list_id).reduce({}) do | acc, v |
      acc[v["name"]] = v["id"]
      acc
    end
  end

  def list_wipe_static_segments
    # TODO: Call this only to unused segments. Internal use only for now.
    list_static_segments.each do | campaign_id, segment_id |
      list_static_segment_delete segment_id
    end
  end

  def find_or_add_static_segment name
    list_static_segment_find(name) || 
    list_static_segment_add(name)
  end

  def list_static_segment_add name
    gb.list_static_segment_add :id => list_id, :name => name
  end

  def list_static_segment_find name
    static_segments = list_static_segments
    static_segments[name]
  end

  def list_static_segment_reset static_segment_id
    gb.list_static_segment_members_add :id => list_id, :seg_id => static_segment_id
  end

  def list_static_segment_delete static_segment_id
    gb.list_static_segment_del :id => list_id, :seg_id => static_segment_id
  end  

  def list_static_segment_members_add static_segment_id, emails
    add_errors_and_return(gb.list_static_segment_members_add({
      :id => list_id,
      :seg_id => static_segment_id,
      :batch => emails
    })) { self["success"] == emails.count }
  end

  # Campaign Related

  def all_campaigns
    gb.campaigns({ :filters => { :list_id => list_id } })
  end

  def campaign_create campaign
    add_errors_and_return(gb.campaign_create({ 
      :type => :regular,
      :options => {
        :list_id => list_id,
        :title => campaign.name,
        :subject => campaign.subject,
        :from_name => campaign.sender.name,
        :from_email => campaign.sender.address,
        :to_name => '*|FNAME|*',
        :generate_text => true,
        :fb_comments => false,
      },
      :content => {
        :html => campaign.message
      }
    })) { gsub(/\"/, '') }
  end

  def campaign_update campaign
    # campaign.pry
  end

  def campaign id
    add_errors_and_return(gb.campaigns({
      :filters => {
        :campaign_id => id
      }
    })) { self["data"].first }
  end

  def campaign_content id
    campaign_content = gb.campaign_content :cid => id
    campaign_content["html"]
  end

  def campaign_send_now id
    gb.campaign_send_now :cid => id
  end

  def campaign_delete id
    gb.campaign_delete :cid => id
  end

  def campaign_update_static_segment id, static_segment_id
    gb.campaign_update :cid => id, :name => "segment_opts", :value => {
      :match => "all",
      :conditions => [{ :field => "static_segment", :op => "eq", :value => static_segment_id }]
    }
  end

  def campaign_schedule id, time
    gb.campaign_schedule :cid => id, :schedule_time => time.utc.strftime('%Y-%m-%d %H:%M:%S')
  end

  def campaign_unschedule id
    gb.campaign_unschedule :cid => id
  end

  private

  def add_errors_and_return(result, &proc)
    if result.is_a?(Hash) && result["error"]
      self.errors ||= [] << result["code"].to_s + ' - ' + result["error"]
      false
    else
      result.instance_eval(&proc)
    end
  end

end