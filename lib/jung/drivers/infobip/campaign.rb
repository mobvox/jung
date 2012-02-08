module Jung::Drivers::Infobip::Campaign

  attr_accessor :username, :password, :api_url, :messages_ids

  def deliver(recipients = self.recipients)
    messages_ids = recipients.map do | recipient |
      address = recipient.is_a?(Jung::Recipient) ? recipient.address : recipient
      deliver_recipient address, message
    end
    delivery_success? messages_ids
  end

  def deliver_test(recipients)
    deliver(recipients)
  end

  protected

  def deliver_recipient address, message
    api.send_sms address, message, sender.name
  end

  def delivery_success?(messages_ids)
    messages_ids.reduce(true) do | acc, value |
      acc && value != false
    end
  end

end