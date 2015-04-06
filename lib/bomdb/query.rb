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
      q
    end

    def print(format: nil, sep: ' ', linesep: '\n', io: $stdout)
      shown = false
      format ||= lambda do |book, chapter, verse|
        "#{book}#{sep}#{chapter}:#{verse}"
      end
      query.each do |row|
        shown = true
        io.print format[
          row[:book_name],
          row[:verse_chapter],
          row[:verse_number]
        ]
        io.print sep
        io.print row[:content_body]
        io.print linesep
      end
      io.puts "Nothing found" unless shown
    end
  end
end