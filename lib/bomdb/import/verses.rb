module BomDB
  module Import
    class Verses < Import::Base
      TABLES = [:books, :verses, :versions, :contents]

      def reset
        schema.reset(*(TABLES - [:books]))
      end

      def json(data)
        if schema.has_tables?(*TABLES)
          ensure_parsed_json(data).each_pair do |book_name, year_versions|
            year_versions.each do |year_version|
              year_version.each_pair do |year, d|
                m = d["meta"]

                book = @db[:books].where(:book_name => book_name).first
                if book.nil?
                  return Import::Result.new(success: false, error: "Unable to find book '#{book_name}'")
                end

                verse = @db[:verses].where(
                  :book_id => book[:book_id],
                  :verse_chapter => m["chapter"],
                  :verse_number  => m["verse"],
                  :verse_heading => m["heading"] ? 0 : nil
                ).first
                verse_id = (verse && verse[:verse_id]) || @db[:verses].insert(
                  book_id: book[:book_id],
                  verse_chapter: m["chapter"],
                  verse_number:  m["verse"],
                  verse_heading: m["heading"] ? 0 : nil
                )

                version = @db[:versions].where(:version_year => year).first
                version_id =  (version && version[:version_id]) || @db[:versions].insert(
                  version_name: year.to_s,
                  version_year: year
                )

                @db[:contents].insert(
                  version_id:   version_id,
                  verse_id:     verse_id,
                  content_body: d["content"]
                )
              end
            end
          end
          Import::Result.new(success: true)
        else
          Import::Result.new(
            success: false,
            error: "Database tables #{TABLES.join(', ')} not ready. Try again with --reset."
          )
        end
      rescue Sequel::UniqueConstraintViolation => e
        Import::Result.new(success: false, error: e)
      end

    end
  end
end