module BomDB
  class Query
    def initialize(edition:, exclude: nil)
      @edition = edition
      @exclude = exclude
    end

    def query(headings: false)
      db = BomDB.db
      q = db[:verses].
        join(:books, :book_id => :book_id).
        join(:versions).
        join(:contents, :version_id => :version_id, :verse_id => :verses__verse_id).
        order(:book_sort, :verse_heading, :verse_chapter, :verse_number).
        select(:book_name, :verse_chapter, :verse_number, :content_body)
      q.where!(:version_name => @edition) if @edition
      q.where!(:verse_heading => nil) unless headings
      q.exclude!(:verses__verse_id => db[:refs].select(:verse_id).where(:ref_name => @exclude)) if @exclude
      # require 'byebug'; byebug
      # p q
      q
    end

    def print(book: true, chapter: true, verse: true, sep: ' ')
      shown = false
      query.each do |row|
        shown = true
        puts [
          book && row[:book_name] || nil,
          (chapter || verse) && [
            chapter && row[:verse_chapter] || nil,
            verse && row[:verse_number] || nil
          ].compact.join(":") || nil,
          row[:content_body]
        ].compact.join(sep)
      end
      puts "Nothing found" unless shown
    end
  end
end