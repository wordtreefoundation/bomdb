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
        book, chapter = nil, nil
        verse_model = Models::Verse.new(@db)
        data.each do |r|
          if r['chapter'] != chapter || r['book'] != book
            # Create a heading per chapter
            Models::Verse.new(@db).find_or_create(
              chapter:   r['chapter'],
              verse:     nil,
              book_name: r['book'],
              heading:   true
            )
            chapter = r['chapter']
          end

          if r['book'] != book
            puts "Importing chapters & verses for '#{r['book']}'"
            book = r['book']
          end

          verse_model.find_or_create(
            chapter:   r['chapter'],
            verse:     r['verse'],
            book_name: r['book'],
            range_id:  r['range_id']
          )
        end
        Import::Result.new(success: true)
      rescue Sequel::UniqueConstraintViolation => e
        Import::Result.new(success: false, error: e)
      end
    end
  end
end
