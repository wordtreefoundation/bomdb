require 'json'

module BomDB
  module Export
    class Verses < Export::Base
      def export_json
        verses = []
        @db[:verses].
          join(:books, :book_id => :book_id).
          where(:verse_heading => nil).
          order(:book_sort, :verse_chapter).
        each do |v|
          verses << { range_id: v[:verse_range_id], book: v[:book_name], chapter: v[:verse_chapter], verse: v[:verse_number] }
        end
        Export::Result.new(success: true, body: JSON.pretty_generate(verses))
      end
    end
  end
end