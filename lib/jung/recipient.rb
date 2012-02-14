module Jung
  class Recipient

    attr_reader :attribute_names
    attr_reader :attributes

    def initialize(attributes)
      @attribute_names = []
      @attributes = {}

      @attribute_names = attributes.keys.uniq.map(&:to_sym)

      attributes.each_pair do |k, v|
        @attributes[k.to_sym] = v
      end
    end

    def get_attribute(attr_name)
      @attributes[attr_name]
    end

    def set_attribute(attr_name, value)
      @attributes[attr_name] = value
    end

    def attribute_method?(method_name)
      match = method_name.to_s.match(/^(?<attr_name>.*?)(?<setter>=?)$/)
      accessor = match[:setter] == '=' ? :set : :get
      attr_name = match[:attr_name].to_sym
      attribute_names.include?(attr_name) ? [accessor, attr_name] : false
    end

    def method_missing(method_name, *args, &block)
      accessor, attr_name = attribute_method?(method_name)
      if accessor
        send("#{accessor}_attribute", attr_name, *args, &block)
      else
        super method_name, *args, &block
      end
    end

    def respond_to?(method_name, include_private = false)
      if attribute_method?(method_name)
        true
      else
        super method_name, include_private
      end
    end

  end
end