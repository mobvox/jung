module Jung::Drivers::Mailchimp::Campaign

  def save
    sync_merge_vars
    sync_members
    sync_campaign
  end

  def deliver
    save
  end

  protected

  def sync_campaign
    if id
      api.campaign_update self
    else
      res = api.campaign_create self
      @id = res if res.class == String
    end
  end

  def all
    api.all_campaigns
  end

end
