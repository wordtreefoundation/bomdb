require 'json'

module BomDB
  module Export
    class Editions < Export::Base
      def export_json
        editions = []
        select_editions.each do |e|
          editions << JSON::generate([e[:edition_year], e[:edition_name]], array_nl: ' ')
        end
        Export::Result.new(success: true, body: "[\n  " + editions.join(",\n  ") + "\n]\n")
      end

      def export_text
        Export::Result.new(success: true, body: select_editions.map{ |e| e[:edition_name] }.join("\n"))
      end

      private

      def select_editions
        @db[:editions].order(:edition_year, :edition_name)
      end
    end
  end
end