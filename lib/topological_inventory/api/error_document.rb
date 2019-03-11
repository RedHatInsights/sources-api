module TopologicalInventory
  module Api
    class ErrorDocument < Hash
      def initialize
        self["errors"] = []
      end

      def add(status, message)
        @status = status
        self["errors"] << {"status" => status, "detail" => message}
        self
      end

      def status
        @status
      end
    end
  end
end
