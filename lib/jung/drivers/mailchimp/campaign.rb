module Jung::Drivers::Mailchimp::Campaign

  def find(id)
    @id = id
    campaign = api.campaign id

    return false if !campaign

    campaign_content = api.campaign_content id
    
    @name = campaign["title"]
    @subject = campaign["subject"]
    @message = campaign_content
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
    api.campaign_send_now id
  end

  def schedule time
    save &&
    api.campaign_schedule(id, time)
  end

  def unschedule
    id &&
    api.campaign_unschedule(id)
  end

  def delete
    delete_static_segment &&
    api.campaign_delete(id) &&
    reset 
  end

  def all
    api.all_campaigns
  end

  protected

  def reset
    @id = nil
    true
  end

  def sync_campaign
    # TODO: Refactor with ||
    if id
      api.campaign_update self
      puts "Not Yet Supported"
    else
      @id = api.campaign_create self
    end
    self.id
  end

  def delete_static_segment
    static_segment_id = api.find_static_segment id
    api.list_static_segment_delete static_segment_id
  end

  def sync_static_segments
    # Dont list_wipe_static_segments yet!
    # api.list_wipe_static_segments
    # The segment name is the campaign internal id. Creates one static segment per campaign
    static_segment_id = api.find_or_add_static_segment id
    api.list_static_segment_reset static_segment_id
    emails = recipients.map { |recipient| recipient.address }
    api.list_static_segment_members_add static_segment_id, emails
    api.campaign_update_static_segment id, static_segment_id
  end

end
