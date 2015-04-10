require 'bomdb/models/verse'

module BomDB
  module Import
    class Contents < Import::Base
      tables :books, :verses, :editions, :contents
      DEFAULT_VERSE_RE = /^\s*(.+)(\d+):(\d+)\s*(.*)$/

      def import_text(data, edition_id:, verse_re: DEFAULT_VERSE_RE, **args)
        data.each_line do |line|
          if line =~ verse_re
            book_name, chapter, verse, content = $1, $2, $3, $4

            book = find_book(book_name)
            return book if book.is_a?(Import::Result)

            verse_id = Models::Verse.new(@db).find_or_create(
              chapter: chapter,
              verse: verse,
              book_id: book[:book_id]
            )

            @db[:contents].insert(
              edition_id:   edition_id,
              verse_id:     verse_id,
              content_body: content
            )
          end
        end
      end

      def import_json(data, edition_id: nil, **args)
        data.each_pair do |book_name, year_editions|
          year_editions.each do |year_edition|
            year_edition.each_pair do |year, d|
              m = d["meta"]

              book = find_book(book_name)
              return book if book.is_a?(Import::Result)

              verse_id = Models::Verse.new(@db).find_or_create(
                chapter: m['chapter'],
                verse: m['verse'],
                book_id: book[:book_id],
                heading: m['heading']
              )

              ed_id = edition_id || find_or_create_edition(year)

              @db[:contents].insert(
                edition_id:   ed_id,
                verse_id:     verse_id,
                content_body: d["content"]
              )
            end
          end
        end
        Import::Result.new(success: true)
      rescue Sequel::UniqueConstraintViolation => e
        Import::Result.new(success: false, error: e)
      end

      protected

      def find_book(book_name)
        book = @db[:books].where(:book_name => book_name).first
        if book.nil?
          Import::Result.new(success: false, error: "Unable to find book '#{book_name}'")
        else
          book
        end
      end

      def find_or_create_edition(year, name = nil)
        name ||= year.to_s
        edition = @db[:editions].where(:edition_year => year).first
        edition_id =  (edition && edition[:edition_id]) || @db[:editions].insert(
          edition_name: name,
          edition_year: year
        )
        return edition_id
      end
    end
  end
end