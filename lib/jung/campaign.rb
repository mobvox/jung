module Jung
  class Campaign < Jung::List

    attr_reader :id
    attr_accessor :name, :sender, :subject, :template
    
    def initialize(options)
      @name = options[:name]
      @subject = options[:subject]
      @sender = options[:sender]
      @template = options[:template]

      super options
    end

  end
end