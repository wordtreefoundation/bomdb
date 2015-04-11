require 'json'

module BomDB
  module Export
    class Books < Export::Base
      def export_json
        books = []
        @db[:books].each do |b|
          books << JSON::generate([ b[:book_name], b[:book_group], b[:book_sort] ], array_nl: ' ')
        end
        Export::Result.new(success: true, body: "[\n  " + books.join(",\n  ") + "\n]\n")
      end
    end
  end
end