require 'json'

module BomDB
  module Export
    class Books < Export::Base
      def export_json
        books = []
        select_books.each do |b|
          fields = [ b[:book_name], b[:book_group], b[:book_sort] ]
          fields << @db[:verses].where(:book_id => b[:book_id]).max(:verse_chapter)
          books << JSON::generate(fields, array_nl: ' ')
        end
        Export::Result.new(success: true, body: "[\n  " + books.join(",\n  ") + "\n]\n")
      end

      def export_text
        Export::Result.new(success: true, body: select_books.map{ |b| b[:book_name] }.join("\n"))
      end

      private

      def select_books
        @db[:books]
      end
    end
  end
end