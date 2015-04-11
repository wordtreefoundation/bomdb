require 'json'

module BomDB
  module Export
    class Verses < Export::Base
      def export_json(**args)
        verses = []
        @db[:verses].join(:books, :book_id => :book_id).
          where(:verse_heading => nil).
          order(:book_sort, :verse_chapter).
          select_group(:book_name, :verse_chapter).
          select_append{ Sequel.as(max(:verse_number), :count) }. 
        each do |v|
          verses << { book: v[:book_name], chapter: v[:verse_chapter], verses: v[:count] }
        end
        Export::Result.new(success: true, body: JSON.pretty_generate(verses))
      end
    end
  end
end