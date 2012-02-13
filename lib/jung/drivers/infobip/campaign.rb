module Jung::Drivers::Infobip::Campaign

  attr_accessor :username, :password, :api_url, :messages_ids
  attr_accessor :app_id # Warning: Infobip limitation: app_id should not be more than 30 chars
  attr_accessor :webhook

  attr_reader :deliver_at
  def deliver_at=(val)
    @deliver_in = nil
    @deliver_at = val
  end

  def deliver_in
    return @deliver_in = nil unless deliver_at.respond_to?(:to_time)

    @deliver_in ||= begin

      time = deliver_at.to_time
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

      time_from_now
    end
  end


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
    self.deliver_at = time
    deliver
  end


  protected

  def delivery_options
    { :appid => app_id, :pushurl => webhook, :sendDateTime => deliver_in }.reject{ |k,v| v.nil? }
  end

  def deliver_recipient address, message
    api.send_sms address, message, sender.name, delivery_options
  end

  def delivery_success?(messages_ids)
    messages_ids.reduce(true) do | acc, value |
      acc && value != false
    end
  end

end