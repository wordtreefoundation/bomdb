require 'json'

module BomDB
  module Import
    class Books < Import::Base
      tables :books

      # Expected data format is:
      # [
      #   [book_name:String, book_group:String, book_sort:Integer],
      #   ...
      # ]
      def import_json(data)
        data.each do |name, group, sort|
          @db[:books].insert(
            book_name: name,
            book_group: group,
            book_sort: sort
          )
        end
        Import::Result.new(success: true)
      rescue Sequel::UniqueConstraintViolation => e
        Import::Result.new(success: false, error: e)
      end
    end
  end
end
