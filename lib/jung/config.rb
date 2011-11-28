module Jung
  class Config

    def initialize(options)
      @drivers = options[:drivers]
    end

    def get_driver_for(type)
      @drivers[type]
    end

  end
end