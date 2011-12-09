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
    merge_vars = recipient.custom_fields.inject({"FNAME" => recipient.name }) do | acc, v |
      acc[v.first.to_s.upcase] = v.last
      acc
    end

    add_errors_and_return(gb.list_subscribe({
      :id => list_id,
      :email_address => recipient.address,
      :merge_vars => merge_vars,
      :double_optin => false,
      :update_existing => true
    })) { self == 'true' }
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
        :html => ''
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

  private

  def add_errors_and_return(result, &proc)
    if result["error"]
      self.errors ||= [] << result["code"].to_s + ' - ' + result["error"]
      false
    else
      result.instance_eval(&proc)
      # proc ? res.instance_eval(&proc) : result
    end
  end

end