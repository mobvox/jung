module Jung::Drivers::Mailchimp

  attr_reader :gb, :list_id, :id
  attr_writer :gb, :list_id

  def self.extended(base)
    base.list_id = base.config.options[:list_id]
    base.gb = Gibbon.new base.config.options[:api_key]
  end

  def deliver
    # puts self.gb.lists({ :filters => { :list_id => self.list_id } }).inspect
    # self.save

    # puts self.gb.list_static_segments({ :id => self.list_id }).inspect
  end

  def save
    @id = self.gb.campaign_create({ 
      :type => :regular,
      :options => {
        :list_id => self.list_id,
        :title => self.name,
        :subject => self.subject,
        :from_name => self.from_name,
        :from_email => self.from_email,
        :to_name => '*|FNAME|*',
        :generate_text => true,
        :fb_comments => false,
      },
      :content => {
        :html => 'aeeee <br /><b>aeee</b>'
      }
    })
    self.id != nil
  end

  def list
    @gb.campaigns({ :filters => { :list_id => @list_id } })
  end

  private

  def send_recipients_to_static_segments
    
  end

end