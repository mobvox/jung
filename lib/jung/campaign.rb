module Jung
  class Campaign < Jung::List
    # attr_accessor
    attr_reader :id, :name, :sender
    
    def initialize(options)
      super options

      @name = options[:name]
      @subject = options[:subject]
      @sender = options[:sender]

      self.load_driver
    end

    def load_driver
      self.extend config.driver_const
    end    

  end
end