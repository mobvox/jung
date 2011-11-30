module Jung
  class List
    attr_reader :config, :recipients
    attr_writer :recipients

    def initialize(options)
      @config = options[:config]
      @recipients = []
    end

    def create_recipient(attributes)
      self.recipients << Jung::Recipient.new(attributes)
    end

  end
end