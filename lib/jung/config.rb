module Jung
  class Config

    attr_reader :driver, :options

    def initialize(options)
      @driver = options[:driver]
      @options = options[:options]
      require 'jung/drivers/' + options[:driver].to_s.underscore + '.rb'
    end

    def driver_const
      Jung::Drivers.const_get self.driver.to_s.camelize
    end

  end
end