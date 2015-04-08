require 'json'

module BomDB
  module Import
    class Refs < Import::Base
      tables :refs

      # Expected data format is:
      # {
      #   (ref_name:String): [
      #     {
      #       "book":String,"chapter":Int,"verse":Int,
      #       "ref_book":String,"ref_chapter":Int,"ref_verse":Int,
      #       "is_parallel":Bool,"is_quotation":Bool
      #     }
      #     ...
      #   ]
      # }
      def import_json(data, **args)
        data.each_pair do |ref_name, rows|
          rows.each do |r|
            verse = @db[:verses].
              join(:books, :book_id => :book_id).
              where(
                book_name:     r['book'],
                verse_chapter: r['chapter'],
                verse_number:  r['verse'],
                verse_heading: nil).
              first
            if verse.nil?
              return Import::Result.new(
                success: false,
                error: "Unable to find verse #{r['book']} #{r['chapter']}:#{r['verse']}"
              )
            end

            @db[:refs].insert(
              verse_id:         verse[:verse_id],
              ref_name:         ref_name,
              ref_book:         r['ref_book'],
              ref_chapter:      r['ref_chapter'],
              ref_verse:        r['ref_verse'],
              ref_is_parallel:  r['is_parallel'],
              ref_is_quotation: r['is_quotation']
            )
          end
        end
        Import::Result.new(success: true)
      rescue Sequel::UniqueConstraintViolation => e
        Import::Result.new(success: false, error: e)
      end

      # def list
      #   @db[
      #     "SELECT book_name, verse_chapter, verse_number, ref_name, ref_book, ref_chapter, ref_verse " +
      #     "FROM `verses` v " +
      #     "JOIN `books` b ON b.book_id = v.book_id " +
      #     "JOIN `refs` r ON r.verse_id = v.verse_id " +
      #     "ORDER BY ref_book, ref_chapter, ref_verse"
      #   ].map(&:inspect).join("\n")
      # end

    end
  end
end
