 module Jung::Drivers::Mailchimp::List

  def save
    sync_merge_vars &&
    sync_members &&
    delete_non_members
  end

  def all
    api.list_members
  end

  protected

  def sync_merge_vars
    return true if recipients.count == 0
    (recipients.map do |recipient|
      api.list_ensure_merge_vars(recipient)
    end).reduce &:&
  end

  def sync_members
    return true if recipients.count == 0
    (recipients.map { |recipient| api.list_subscribe(recipient) }).reduce &:&
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
    true
  end

end