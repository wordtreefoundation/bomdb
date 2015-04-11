require 'json'

module BomDB
  module Import
    class Base
      attr_reader :db, :opts

      def initialize(db, **opts)
        @db = db
        @opts = opts
      end

      def self.tables(*tables)
        @tables = tables
      end

      def tables
        self.class.instance_variable_get("@tables")
      end

      def import(data, format: 'json')
        if !schema.has_tables?(tables)
          return Import::Result.new(
            success: false,
            error: "Database table(s) not present: [#{tables.join(', ')}]"
          )
        end

        case format
        when 'json' then import_json(ensure_parsed_json(data))
        when 'text' then import_text(data)
        else
          return Import::Result.new(
            success: false,
            error: "Unknown format: #{format}"
          )
        end
      end

      def ensure_parsed_json(data)
        if data.is_a?(String)
          JSON.parse(data)
        else
          data
        end
      end

      def schema
        BomDB::Schema.new(@db)
      end
    end
  end
end