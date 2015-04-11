module BomDB
  module Export
    class Base
      def initialize(db)
        @db = db
      end

      def export(format: 'json', **options)
        case format
        when 'json' then export_json(**options)
        when 'text' then export_text(**options)
        else
          return Import::Result.new(
            success: false,
            error: "Unknown format: #{format}"
          )
        end
      end
    end
  end
end