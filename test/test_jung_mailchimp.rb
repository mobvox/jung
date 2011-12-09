require 'helper'

class TestJung < Test::Unit::TestCase

  def config
    config_file_name = File.join(Pathname.new(__FILE__).dirname, "config/jung.yml")
    @config ||= Jung::Config.load config_file_name, :test_mailchimp
  end

  def test_list_save
    list = Jung::List.new :config => config

    list.create_recipient :name => 'Lorem', :address => 'lorem@mobvox.com.br', :custom_fields => { :sex => 'm', :function => "Developer", :phone => '33554466' }
    list.create_recipient :name => 'Ipsum', :address => 'ipsum@mobvox.com.br', :custom_fields => { :sex => 'm', :function => "Developer" }
    list.create_recipient :name => 'Dolor', :address => 'dolor@mobvox.com.br', :custom_fields => { :sex => 'm', :function => "Developer" }
    list.create_recipient :name => 'Sit', :address => 'sit@mobvox.com.br', :custom_fields => { :sex => 'm', :function => "Developer" }
    list.create_recipient :name => 'Amet', :address => 'amet@mobvox.com.br', :custom_fields => { :sex => 'm', :function => "Developer" }
    list.create_recipient :name => 'Consectetur', :address => 'consectetur@mobvox.com.br', :custom_fields => { :sex => 'f', :function => "Developer" }
    list.create_recipient :name => 'Adipiscing', :address => 'adipiscing@mobvox.com.br', :custom_fields => { :sex => 'm', :function => "Psychologist" }

    assert list.save
  end

  def test_campaign_save_find_delete
    # First lets save a campaign
    rand = rand(123 * 456)
    campaign = Jung::Campaign.new({
      :config => config,
      :name => 'JUNG TEST - Lorem ipsum dolor. #' + rand.to_s,
      :subject => 'Fusce tempus, nibh eleifend feugiat lobortis.',
      :sender => Jung::Sender.new('Lorem ipsum', 'contato@mobvox.com.br')
    })
    campaign.create_recipient :name => 'Lorem', :address => 'lorem@mobvox.com.br', :custom_fields => { :sex => 'm', :function => "Developer", :phone => '33554466' }
    campaign.create_recipient :name => 'Ipsum', :address => 'ipsum@mobvox.com.br', :custom_fields => { :sex => 'm', :function => "Developer" }
    id = campaign.save
    assert id != nil
    
    # Now lets "find" the campaign
    campaign = Jung::Campaign.new :config => config
    if !campaign.find id
      puts campaign.errors.inspect
    end
    assert campaign.id != nil

    # And delete it!
    assert campaign.delete
  end

  def test_campaign_schedule_unschedule_delete
    # First lets define a campaign
    rand = rand(123 * 456)
    campaign = Jung::Campaign.new({
      :config => config,
      :name => 'JUNG TEST - Lorem ipsum dolor. #' + rand.to_s,
      :subject => 'Fusce tempus, nibh eleifend feugiat lobortis.',
      :sender => Jung::Sender.new('Lorem ipsum', 'contato@mobvox.com.br')
    })

    # Add one recipient
    campaign.create_recipient :name => 'Lorem', :address => 'lorem@mobvox.com.br', :custom_fields => { :sex => 'm', :function => "Developer", :phone => '33554466' }
    
    campaign.subject = campaign.name
    campaign.template = campaign.name

    assert campaign.schedule Time.now + (60 * 60 * 24)
    assert campaign.unschedule
    # assert campaign.deliver
    assert campaign.delete
  end

end