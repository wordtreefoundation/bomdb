require 'json'

module BomDB
  module Export
    class Books < Export::Base
      def export_json(**args)
        books = []
        @db[:books].each do |b|
          books << [b[:book_name], b[:book_group], b[:book_sort]]
        end
        Export::Result.new(success: true, body: JSON.pretty_generate(books))
      end
    end
  end
end