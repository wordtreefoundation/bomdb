module BomDB
  module Export
    class Result
      attr_reader :success, :error, :body

      def initialize(success:, body: nil, error: nil)
        @success = success
        @error = error
        @body = body
      end

      def success?
        @success
      end

      def to_s
        @body
      end

      def message
        if @success
          "Succeeded"
        else
          @error.to_s
        end
      end
    end
  end
end