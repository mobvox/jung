# -*- encoding: utf-8 -*-

module Jung::Drivers::Infobip

  module SmsCounter

    @gsm7bitChars = "@£$¥èéùìòÇ\nØø\rÅåΔ_ΦΓΛΩΠΨΣΘΞÆæßÉ !\"#¤%&'()*+,-./0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüà"
    @gsm7bitExChar = "^{}\\[~]|€"

    @gsm7bitRegExp = Regexp.new("^[#{Regexp.escape(@gsm7bitChars)}]*$")
    @gsm7bitExRegExp = Regexp.new("^[#{Regexp.escape(@gsm7bitChars)}#{Regexp.escape(@gsm7bitExChar)}]*$")
    @gsm7bitExOnlyRegExp = Regexp.new("^[\\#{Regexp.escape(@gsm7bitExChar)}]*$")

    @messageLength = {
      :gsm_7bit => 160,
      :gsm_7bit_ex => 160,
      :utf16 => 70
    }

    @multiMessageLength = {
      :gsm_7bit => 153,
      :gsm_7bit_ex => 153,
      :utf16 => 67
    }

    def self.count(text)
      encoding = detectEncoding(text)

      length = text.length
      length += countGsm7bitEx(text) if encoding == :gsm_7bit_ex

      per_message = @messageLength[encoding]
      per_message = @multiMessageLength[encoding] if length > per_message

      messages = (length.to_f / per_message).ceil
      remaining = (per_message * messages) - length

      {
        :encoding => encoding,
        :length => length,
        :per_message => per_message,
        :remaining => remaining,
        :messages => messages
      }
    end

    def self.detectEncoding(text)
      case
        when text.match(@gsm7bitRegExp) then :gsm_7bit
        when text.match(@gsm7bitExRegExp) then :gsm_7bit_ex
        else :utf16
      end
    end

    def self.countGsm7bitEx(text)
      chars = text.each_char.select {|char| char.match(@gsm7bitExOnlyRegExp) }
      chars.size
    end

  end

end
