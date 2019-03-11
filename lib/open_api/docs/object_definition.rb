module OpenApi
  class Docs
    class ObjectDefinition < Hash
      def all_attributes
        properties.keys
      end

      def read_only_attributes
        properties.select { |k, v| v["readOnly"] == true }.keys
      end

      def required_attributes
        self["required"]
      end

      def properties
        self["properties"]
      end
    end
  end
end
