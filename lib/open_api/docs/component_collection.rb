module OpenApi
  class Docs
    class ComponentCollection < Hash
      attr_reader :doc

      def initialize(doc, category)
        @doc = doc
        @category = category
      end

      def [](name)
        super || load_definition(name)
      end

      def load_definition(name)
        raw_definition = @doc.content[@category][name]
        raise ArgumentError, "Failed to find definition for #{name}" unless raw_definition.kind_of?(Hash)

        definition = substitute_regexes(raw_definition)
        definition = substitute_references(definition)
        self[name] = OpenApi::Docs::ObjectDefinition.new.replace(definition)
      end

      private

      def substitute_references(object)
        if object.kind_of?(Array)
          object.collect { |i| substitute_references(i) }
        elsif object.kind_of?(Hash)
          return fetch_ref_value(object["$ref"]) if object.keys == ["$ref"]
          object.each { |k, v| object[k] = substitute_references(v) }
        else
          object
        end
      end

      def fetch_ref_value(ref_path)
        _, section, property = ref_path.split("/")
        public_send(:[], property)
      end

      def substitute_regexes(object)
        if object.kind_of?(Array)
          object.collect { |i| substitute_regexes(i) }
        elsif object.kind_of?(Hash)
          object.each do |k, v|
            object[k] = k == "pattern" ? regexp_from_pattern(v) : substitute_regexes(v)
          end
        else
          object
        end
      end

      def regexp_from_pattern(pattern)
        raise "Pattern #{pattern.inspect} is not a regular expression" unless pattern.starts_with?("/") && pattern.ends_with?("/")
        Regexp.new(pattern[1..-2])
      end
    end
  end
end
