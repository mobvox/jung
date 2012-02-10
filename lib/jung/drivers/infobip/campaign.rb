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

  def schedule time
    seconds_from_now = (Time.now - time) * -1

    unless seconds_from_now < 0
      minutes_from_now, seconds_from_now = seconds_from_now.divmod(60)
      hours_from_now, minutes_from_now = minutes_from_now.divmod(60)
      days_from_now, hours_from_now = hours_from_now.divmod(24)
      seconds_from_now = seconds_from_now.to_i

      time_from_now = { 
        :d => days_from_now,
        :h => hours_from_now,
        :m => minutes_from_now,
        :s => seconds_from_now
      }.reject { |k,v| v == 0 }.map { |(k,v)| "#{v}#{k}" }.join
    else
      time_from_now = nil
    end

    messages_ids = recipients.map do | recipient |
      address = recipient.is_a?(Jung::Recipient) ? recipient.address : recipient
      schedule_recipient address, message, time_from_now
    end
    delivery_success? messages_ids
  end

  protected

  def deliver_recipient address, message
    api.send_sms address, message, sender.name
  end

  def schedule_recipient address, message, time_from_now = nil
    api.schedule_sms address, message, sender.name, time_from_now
  end

  def delivery_success?(messages_ids)
    messages_ids.reduce(true) do | acc, value |
      acc && value != false
    end
  end

end