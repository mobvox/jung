module Jung
  class Sender
    attr_reader :name, :address
    attr_writer :name, :address

    def initialize(name, address)
      @name = name
      @address = address
    end

  end
end