module Jung
  class List
    attr_reader :config, :recipients
    attr_writer :recipients

    def initialize(options)
      @config = options[:config]
      @recipients = []

      self.load_driver
    end

    def load_driver
      self.extend config.driver_const
    end

    def create_recipient(attributes)
      self.recipients << Jung::Recipient.new(attributes)
    end

    def find_recipient_by_address(address)
      recipients.each do |recipient|
        return recipient if recipient.address == address
      end
      return nil
    end

  end
end