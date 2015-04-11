module BomDB
  module Export
    class Base
      attr_reader :db, :opts

      def initialize(db, **opts)
        @db = db
        @opts = opts
      end

      def export(format: 'json', **options)
        case format
        when 'json' then export_json
        when 'text' then export_text
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