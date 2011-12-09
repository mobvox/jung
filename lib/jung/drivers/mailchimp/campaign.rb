module Jung::Drivers::Mailchimp::Campaign

  def find(id)
    @id = id
    campaign = api.campaign id

    return false if !campaign

    campaign_content = api.campaign_content id
    
    @name = campaign["title"]
    @subject = campaign["subject"]
    @template = campaign_content
    @sender = Jung::Sender.new(campaign["from_name"], campaign["from_email"])
  end

  def save
    if sync_merge_vars &&
       sync_members &&
       sync_campaign &&
       sync_static_segments
      @id
    end
  end

  def deliver
    save
    # api.campaign_send_now id
  end

  def delete
    api.campaign_delete id
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

  def sync_static_segments
    # api.list_static_segment_members_add
    self.pry
  end

  def all
    api.all_campaigns
  end

end
