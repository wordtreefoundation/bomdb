require 'json'
require 'bomdb/models/edition'

module BomDB
  module Export
    class Contents < Export::Base
      def export_json
        editions_by_id = selected_editions()

        contents = {}
        content_query(editions_by_id.keys).each do |r|
          edition = editions_by_id[ r[:edition_id] ]
          book    = (contents[ r[:book_name] ] ||= {})
          chapter = (book[ r[:verse_chapter] ] ||= {})
          verse   = (chapter[ full_verse_ref(r) ] ||= {})
          verse[ edition[:edition_year] ] = r[:content_body]
        end

        frame = {
          editions: editions_legend(editions_by_id),
          contents: contents
        }

        Export::Result.new(success: true, body: JSON.pretty_generate(frame))
      end

      def export_text
        editions_by_id = selected_editions()

        output = ""
        editions_by_id.each_pair do |id, edition|
          title = edition[:edition_name]
          output << title + "\n"
          output << ('=' * title.size) + "\n"

          content_query([id]).each do |r|
            output << full_verse_ref(r) + "\t" + r[:content_body] + "\n"
          end

          output << "\n"
        end

        Export::Result.new(success: true, body: output)
      end

      protected

      def editions_legend(editions_by_id)
        {}.tap do |editions|
          editions_by_id.each_pair do |id, row|
            year, name = row[:edition_year], row[:edition_name]
            editions[ year ] = { year: year, name: name }
          end
        end
      end

      def selected_editions
        {}.tap do |editions_by_id|
          if opts[:edition_prefixes] == :all
            # "all" means all editions that actually have content
            edition_query.each do |e|
              editions_by_id[ e[:edition_id] ] = e
            end
          else
            # export editions that are mentioned by name-prefix
            ed_model = Models::Edition.new(@db)
            opts[:edition_prefixes].split(/\s*,\s*/).each do |epat|
              e = ed_model.find(epat)
              editions_by_id[ e[:edition_id] ] = e
            end
          end
        end
      end

      def edition_query
        @db[:editions].
          left_outer_join(:contents, :edition_id => :edition_id).
          select_group(Sequel.qualify("editions", "edition_id"), :edition_year, :edition_name).
          select_append{ Sequel.as(count(:verse_id), :count) }.
          having{ count > 0 }.
          order(:edition_name)
      end

      def content_query(edition_ids)
        @db[:verses].
          join(:books, :book_id => :book_id).
          join(:editions).
          join(:contents, :edition_id => :edition_id, :verse_id => Sequel.qualify("verses", "verse_id")).
          order(:book_sort, :verse_heading, :verse_chapter, :verse_number).
          select(Sequel.qualify("editions", "edition_id"), :book_name, :verse_chapter, :verse_number, :content_body).
          where(Sequel.qualify("editions", "edition_id") => edition_ids).
          where(:verse_heading => nil)
      end

      def full_verse_ref(row)
        "#{row[:book_name]} #{row[:verse_chapter]}:#{row[:verse_number]}"
      end
    end
  end
end