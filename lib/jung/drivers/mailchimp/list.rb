module Jung::Drivers::Mailchimp::List

  def save
    sync_merge_vars && sync_members && delete_non_members
  end

  def all
    list_members
  end

  def errors
  end

  protected

  def sync_merge_vars
    recipients.each do |recipient|
      sync_recipient_merge_vars recipient
    end
  end

  def sync_recipient_merge_vars(recipient)
    recipient.custom_fields.each do |var, value|
      api.list_merge_var_add var
    end
  end

  def sync_members
    recipients.each do |recipient| 
      api.list_subscribe recipient
    end
  end

  def delete_non_members
    # Unsubscribe non-existing members
    # Call this method *ONLY* with a full list of all members
    current_members = api.list_members
    current_members.each do |member|
      res = find_recipient_by_address member.address
      if !find_recipient_by_address member.address
        api.list_unsubscribe member.address
      end
    end
  end

end