require 'bomdb/models/verse'
require 'bomdb/models/edition'

module BomDB
  module Import
    class Contents < Import::Base
      tables :books, :verses, :editions, :contents
      DEFAULT_VERSE_CONTENT_RE = /^\s*(.+)\s+(\d+):(\d+)\s+(.*)$/
      DEFAULT_VERSE_REF_RE     = /^\s*(.+)\s+(\d+):(\d+)$/
      MAX_DUPS = 5

      def import_text(data)
        if opts[:edition_prefix].nil?
          return Import::Result.new(success: false,
            error: "'--edition' is required for text import of contents"
          )
        end

        edition_model = Models::Edition.new(@db)

        edition = edition_model.find(opts[:edition_prefix])
        if edition.nil?
          return Import::Result.new(success: false,
            error: "Edition matching prefix '#{opts[:edition_prefix]}' not found"
          )
        end
        edition_id = edition[:edition_id]

        verse_re = opts[:verse_re] || DEFAULT_VERSE_CONTENT_RE

        times_tried = 0
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

            begin
              @db[:contents].insert(
                edition_id:   edition_id,
                verse_id:     verse_id,
                content_body: content
              )
            rescue Sequel::UniqueConstraintViolation => e
              msg = "edition_id: #{edition_id}, verse: '#{book_name} #{chapter}:#{verse}', content: #{content.inspect}"
              $stderr.puts "Warning: duplicate #{msg}"
              times_tried += 1
              if times_tried > MAX_DUPS
                return Import::Result.new(success: false,
                  error: "Too many duplicate rows. Stopped at #{msg}"
                )
              else
                next
              end
            end
          end
        end
        Import::Result.new(success: true)
      end

      def import_json(data)
        # this cross-ref is for looking up file-edition-id => database-edition-id
        editions_xref = {}

        ed_model = Models::Edition.new(@db)
        verse_model = Models::Verse.new(@db)

        data['editions'].each_pair do |id, e|
          editions_xref[ id ] = ed_model.find_or_create(e["year"].to_i, e["name"])
        end

        data['contents'].each_pair do |book_name, chapters|
          chapters.each_pair do |chapter, verses|
            verses.each_pair do |verse_full_ref, editions|
              match = DEFAULT_VERSE_REF_RE.match(verse_full_ref)
              if match
                verse_number = match[3].to_i
                verse = verse_model.find(
                  book_name: book_name,
                  chapter: chapter,
                  verse: verse_number
                )
                if verse.nil?
                  return Import::Result.new(success: false,
                    error: "Unable to find verse: book: " +
                           "'#{book_name}', chapter: '#{chapter}', " +
                           "verse: '#{verse_number}'")
                end
                editions.each_pair do |file_edition_id, content_body|
                  @db[:contents].insert(
                    edition_id: editions_xref[ file_edition_id ],
                    verse_id: verse[:verse_id],
                    content_body: content_body
                  )
                end
              else
                $stderr.puts "Unable to parse verse ref from '#{verse_full_ref}', skipping"
              end
            end
          end
        end
        Import::Result.new(success: true)
      end

      def import_json_old(data)
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

              ed_id = opts[:edition_id] || find_or_create_edition(year)

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