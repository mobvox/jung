module Jung
  class Campaign < Jung::List

    attr_reader :id
    attr_accessor :name, :sender, :subject, :message
    
    def initialize(options)
      @name = options[:name]
      @subject = options[:subject]
      @sender = options[:sender]
      @message = options[:message]

      super options
    end

  end
end