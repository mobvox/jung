module Jung
  class Recipient

    attr_reader :name, :address, :custom_fields

    def initialize(attributes)
      @name = attributes[:name]
      @address = attributes[:address]
      @custom_fields = attributes[:custom_fields]
    end

  end
end