module Jung::Drivers::Mailchimp

  attr_reader :gb, :list_id, :api, :id
  attr_writer :gb, :list_id, :api

  def self.extended(base)
    base.extend case
      when Jung::List then Jung::Drivers::Mailchimp::List
      when Jung::Campaign then Jung::Drivers::Mailchimp::Campaign
    end
    base.list_id = base.config.options[:list_id]
    base.api = Api.new base.config
  end

  class Api

    attr_reader :gb, :list_id

    def initialize(config)
      @gb = Gibbon.new config.options[:api_key]
      @list_id = config.options[:list_id]
    end

    def list_merge_var_add(merge_var)
      tag = merge_var.to_s.upcase
      name = tag.capitalize

      @merge_vars ||= self.list_merge_vars

      return unless @merge_vars.include? tag

      gb.list_merge_var_add({
        :id => list_id,
        :tag => tag,
        :name => name
      })

      # Cache is never ugly
      @merge_vars << tag
    end

    def list_merge_vars
      merge_vars_array = self.gb.list_merge_vars :id => self.list_id
      merge_vars_array.map { |e| e["tag"] }
    end

    def list_subscribe(recipient)
      merge_vars = recipient.custom_fields.inject({"FNAME" => recipient.name }) do | acc, v |
        acc[v.first.to_s.upcase] = v.last
        acc
      end

      self.gb.list_subscribe({
        :id => list_id,
        :email_address => recipient.address,
        :merge_vars => merge_vars,
        :double_optin => false,
        :update_existing => true
      })
    end

    def list_unsubscribe(address)
      self.gb.list_unsubscribe({
        :id => list_id,
        :email_address => address,
        :delete_member => false,
        :send_goodbye => false
      })
    end

    def list_members
      current_members = []
      members_array = self.gb.list_members :id => self.list_id, :limit => 15000
      members_array["data"].each do |member|
        # TODO: Batch this method (Mailchimp supports up to 50 per call)
        info = self.gb.list_member_info :id => self.list_id, :email_address => member["email"]
        current_members << Jung::Recipient.new({
          :name => info["data"][0]["merges"]["FNAME"],
          :address => member["email"],
          :custom_fields => info["data"][0]["merges"]
        })
      end
      current_members
    end

  end

  module List
    
    def save
      self.sync_merge_vars
      self.sync_members
    end

    protected

    def sync_merge_vars
      recipients.each do |recipient|
        sync_merge_vars_recipient recipient
      end
    end

    def sync_recipient_merge_vars(recipient)
      recipient.custom_fields.each do |var, value|
        api.list_merge_var_add var
      end
    end

    def sync_members
      # First we need to unsubscribe non-existing members
      current_members = api.list_members
      current_members.each do |member|
        res = self.find_recipient_by_address member.address
        if !self.find_recipient_by_address member.address
          api.list_unsubscribe member.address
        end
      end

      # Now update/add the members
      self.recipients.each do |recipient| 
        api.list_subscribe
      end
    end
  end

  module Campaign

    def deliver
      # puts self.gb.lists({ :filters => { :list_id => self.list_id } }).inspect
      # self.save

      # puts self.gb.list_static_segments({ :id => self.list_id }).inspect
    end

    def save
      @id = self.gb.campaign_create({ 
        :type => :regular,
        :options => {
          :list_id => self.list_id,
          :title => self.name,
          :subject => self.subject,
          :from_name => self.from_name,
          :from_email => self.from_email,
          :to_name => '*|FNAME|*',
          :generate_text => true,
          :fb_comments => false,
        },
        :content => {
          :html => 'aeeee <br /><b>aeee</b>'
        }
      })
      self.id != nil
    end

    def all
      @gb.campaigns({ :filters => { :list_id => @list_id } })
    end

  end

end