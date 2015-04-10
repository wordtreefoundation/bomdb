require 'json'
require 'bomdb/models/verse'

module BomDB
  module Import
    class Verses < Import::Base
      tables :books, :verses

      # Expected data format is:
      # [
      #   {
      #     "book": String,
      #     "chapter": Int,
      #     "verses": Int
      #   },
      #   ...
      # ]
      def import_json(data, **args)
        data.each do |r|
          # Create a heading per chapter
          Models::Verse.new(@db).find_or_create(
            chapter:   r['chapter'],
            verse:     nil,
            book_name: r['book'],
            heading:   true
          )

          # Create as many verses as is called for per chapter
          (1..r['verses']).each do |verse_number|
            Models::Verse.new(@db).find_or_create(
              chapter:   r['chapter'],
              verse:     verse_number,
              book_name: r['book']
            )
          end
        end
        Import::Result.new(success: true)
      rescue Sequel::UniqueConstraintViolation => e
        Import::Result.new(success: false, error: e)
      end
    end
  end
end
