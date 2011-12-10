module Jung::Drivers::Infobip

  require 'jung/drivers/infobip/api.rb'
  require 'jung/drivers/infobip/campaign.rb'

  attr_reader :list_id, :api, :id
  attr_writer :list_id, :api

  def self.extended(base)
    return if base.class != Jung::Campaign
    base.extend Jung::Drivers::Infobip::Campaign
    base.api = Api.new base.config
  end

end