require 'helper'

class TestJung < Test::Unit::TestCase

  def config
    config_file_name = File.join(Pathname.new(__FILE__).dirname, "config/jung.yml")
    @config ||= Jung::Config.load config_file_name, :test_infobip
  end

  def test_campaign_deliver
    # First lets define a campaign
    rand = rand(123 * 456)
    campaign = Jung::Campaign.new({
      :config => config,
      :name => 'JUNG TEST - Lorem ipsum dolor. #' + rand.to_s,
      :sender => Jung::Sender.new('Lorem ipsum')
    })

    # Add the recipients
    campaign.create_recipient :name => 'Lorem', :address => config.options["fixtures"]["test_phone1"]
    campaign.create_recipient :name => 'Lipsum', :address => config.options["fixtures"]["test_phone2"]
    
    campaign.message = campaign.name

    assert campaign.deliver

  end

end