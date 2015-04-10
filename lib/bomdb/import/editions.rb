require 'json'

module BomDB
  module Import
    class Editions < Import::Base
      tables :editions

      # Expected data format is:
      # [
      #   [edition_year:Integer, edition_name:String],
      #   ...
      # ]
      def import_json(data, **args)
        data.each do |year, name|
          @db[:editions].insert(
            edition_year: year,
            edition_name: name
          )
        end
        Import::Result.new(success: true)
      rescue Sequel::UniqueConstraintViolation => e
        Import::Result.new(success: false, error: e)
      end
    end
  end
end
