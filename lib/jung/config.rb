module Jung
  class Config

    attr_reader :driver, :options

    def self.load(file = "config/jung.yml", namespace = nil)
      options = YAML.load_file file
      return self.new options[namespace.to_s]
    end

    def initialize(options)
      @driver = options["driver"]
      @options = options["options"]
      Jung::Drivers.load options["driver"]
    end

    def driver_const
      Jung::Drivers.const_get self.driver.camelize
    end

  end
end