require 'json'

module BomDB
  module Import
    class Base
      def initialize(db)
        @db = db
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