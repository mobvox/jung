module Jung
  class Campaign < Jung::List
    # attr_accessor
    attr_reader :name, :sender, :subject, :template, :id
    attr_writer :name, :sender, :subject, :template
    
    def initialize(options)
      @name = options[:name]
      @subject = options[:subject]
      @sender = options[:sender]
      @template = options[:template]

      super options
    end

  end
end