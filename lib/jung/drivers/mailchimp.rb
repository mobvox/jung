module Jung::Drivers::Mailchimp

  require 'jung/drivers/mailchimp/api.rb'
  require 'jung/drivers/mailchimp/list.rb'
  require 'jung/drivers/mailchimp/campaign.rb'

  attr_reader :gb, :list_id, :api, :id
  attr_writer :gb, :list_id, :api

  def self.extended(base)
    base.extend Jung::Drivers::Mailchimp::List
    base.extend Jung::Drivers::Mailchimp::Campaign if base.class == Jung::Campaign
  
    base.list_id = base.config.options[:list_id]
    base.api = Api.new base.config
  end

  def errors
    api.errors
  end

end