module Jung
  class Recipient

    def initialize(attributes)
      @name = attributes[:name]
      @address = attributes[:address]
      @custom_fields = attributes[:custom_fields]
    end

  end
end