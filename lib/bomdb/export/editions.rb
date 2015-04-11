require 'json'

module BomDB
  module Export
    class Editions < Export::Base
      def export_json
        editions = []
        @db[:editions].order(:edition_year, :edition_name).each do |e|
          editions << JSON::generate([e[:edition_year], e[:edition_name]], array_nl: ' ')
        end
        Export::Result.new(success: true, body: "[\n  " + editions.join(",\n  ") + "\n]\n")
      end
    end
  end
end