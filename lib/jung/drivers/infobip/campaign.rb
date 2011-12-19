module Jung::Drivers::Infobip::Campaign

  attr_accessor :username, :password, :api_url, :messages_ids

  def deliver
    messages_ids = recipients.map do | recipient |
      deliver_recipient recipient.address, message
    end
    messages_ids.reduce(true) do | acc, value |
      acc && value != false
    end
  end

  protected

  def deliver_recipient address, message
    api.send_sms address, message, sender.name
  end

end