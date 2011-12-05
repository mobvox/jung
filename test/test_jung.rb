require 'helper'

class TestJung < Test::Unit::TestCase
  
    def test_list_save
      config = Jung::Config.new({
        :driver => :mailchimp,
        :options => {
          :api_key => '2e71b5b668fe17a566c88acc3d6725af-us2',
          :list_id => '979b672d01'
        }
      })

      list = Jung::List.new :config => config
      list.create_recipient :name => 'Ariel', :address => 'ariel@mobvox.com.br', :custom_fields => { :sex => 'm', :function => "Developer" }
      list.create_recipient :name => 'Daniel', :address => 'daniel@mobvox.com.br', :custom_fields => { :sex => 'm', :function => "Developer" }
      list.create_recipient :name => 'Danilo', :address => 'danilo@mobvox.com.br', :custom_fields => { :sex => 'm', :function => "Developer" }
      list.create_recipient :name => 'Jonas', :address => 'jonas@mobvox.com.br', :custom_fields => { :sex => 'm', :function => "Developer" }
      list.create_recipient :name => 'Fernando', :address => 'fernando@mobvox.com.br', :custom_fields => { :sex => 'm', :function => "Developer" }
      list.create_recipient :name => 'Yara', :address => 'yara@mobvox.com.br', :custom_fields => { :sex => 'f', :function => "Developer" }
      list.create_recipient :name => 'Carl Jung', :address => 'jung@mobvox.com.br', :custom_fields => { :sex => 'm', :function => "Psychologist" }
      list.create_recipient :name => 'Caio', :address => 'caio@mobvox.com.br', :custom_fields => { :sex => 'm', :function => "Att" }
      list.create_recipient :name => 'Mônica', :address => 'monica@mobvox.com.br', :custom_fields => { :sex => 'f', :function => "Att" }
      
      assert list.save
    end

end