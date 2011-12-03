module Jung
  class Campaign < Jung::List
    # attr_accessor
    attr_reader :id, :name, :sender, :subject
    
    def initialize(options)
      @name = options[:name]
      @subject = options[:subject]
      @sender = options[:sender]

      super options
    end

  end
end