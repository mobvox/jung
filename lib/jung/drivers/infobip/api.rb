class Jung::Drivers::Infobip::Api

  require 'net/http'

  attr_reader :username, :password, :api_url, :errors, :error_messages
  attr_writer :errors

  def initialize(config)
    @username = config.options["username"]
    @password = config.options["password"]
    @api_url = config.options["api_url"]

    @error_messages = {
      -2 => "Not enough credits",
      -3 => "Network not covered",
      -5 => "Invalid username or password",
      -6 => "Missing destination address",
      -7 => "Missing SMS text",
      -8 => "Missing sender name",
      -9 => "Invalid format of destination address",
      -10 => "Missing username",
      -11 => "Missing password",
      -13 => "Invalid destination address"
    }
  end

  def send_sms(address, message, sender)
    do_get_request :sendsms, :GSM => address, :SMSText => message, :sender => sender, :DataCoding => '8'
  end

  private

  def get_error_message id
    error_messages[id.to_i] || 'Unknow error ID: ' + id
  end

  def do_get_request method, params
    url  = api_url + '/' + method.to_s + '/plain?user=' + username + '&password=' + password
    url = params.reduce(url) do | url, param |
      url + '&' +  CGI.escape(param.first.to_s) + '=' + CGI.escape(param.last.to_s)
    end
    result = Net::HTTP.get_response(URI.parse(url)).body
   
    self.errors ||= [] << 'url: ' + url + ' - ' + get_error_message(result)
    
    result.to_i > 1 ? result : false
  end

end