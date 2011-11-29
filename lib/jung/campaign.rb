module Jung
  class Campaign
    # attr_accessor
    attr_reader :id, :recipients, :config, :name
    attr_writer :recipients

    def initialize(options)
      @name = options[:name]
      @config = options[:config]
      @recipients = []
    end

    def self.build(type, options)
      constant = Jung.const_get type.to_s.capitalize + 'Campaign'
      constant.new options
    end

    def create_recipient(attributes)
      self.recipients << Jung::Recipient.new(attributes)
    end

  end
end