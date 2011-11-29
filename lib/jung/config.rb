module Jung
  class Config

    attr_reader :options

    def initialize(options)
      @options = options
      require 'jung/drivers/email/' + options[:drivers][:email].to_s.underscore + '.rb'
    end

    def email_driver
      Jung::Drivers::Email.const_get self.options[:drivers][:email].to_s.camelize
    end

  end
end