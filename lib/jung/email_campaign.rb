module Jung
  class EmailCampaign < Campaign
    
    attr_reader :title, :subject, :from_name, :from_email

    def initialize(options)
      super options

      @subject = options[:subject]
      @from_email = options[:from_email]
      @from_name = options[:from_name]

      self.load_email_driver
    end

    def load_email_driver
      self.extend config.email_driver
    end

    def type
      return :email
    end

  end
end