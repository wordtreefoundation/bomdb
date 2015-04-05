module BomDB
  module Import
    class Result
      attr_reader :success, :error

      def initialize(success:, error: nil)
        @success = success
        @error = error
      end

      def success?
        @success
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