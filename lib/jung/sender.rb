module Jung
  class Sender

    attr_accessor :name, :address

    def initialize(name, address = nil)
      @name = name
      @address = address
    end

  end
end