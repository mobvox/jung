module Jung
  class Campaign
    attr_reader :recipients
    attr_writer :recipients

    def initialize(options)
      @name = options[:name]
      @config = options[:config]
      @recipients = []
    end

    def self.build(type, options)
      driver = options[:config].get_driver_for type
      class_name = driver.to_s.capitalize + type.to_s.capitalize + 'Driver';
      require 'jung/drivers/' + class_name.underscore + '.rb'
      eval 'Campaign.send :include, ' + class_name
      eval type.to_s.capitalize + 'Campaign.new options'
    end
  end
end