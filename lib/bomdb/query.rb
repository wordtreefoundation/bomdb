require 'bomdb/models/edition'

module BomDB
  class Query
    def initialize(edition:, exclude: nil, headings: false)
      @edition = edition
      @exclude = exclude
      @headings = headings
    end

    def query
      db = BomDB.db
      edition_model = Models::Edition.new(db)
      edition = edition_model.find(@edition)
      if edition.nil?
        raise "Unable to find edition: #{@edition}"
      end
      q = db[:verses].
        join(:books, :book_id => :book_id).
        join(:editions).
        join(:contents, :edition_id => :edition_id, :verse_id => :verses__verse_id).
        order(:book_sort, :verse_heading, :verse_chapter, :verse_number).
        select(:book_name, :verse_chapter, :verse_number, :content_body)
      q.where!(:editions__edition_id => edition[:edition_id]) if @edition
      q.where!(:verse_heading => nil) unless @headings
      q.exclude!(:verses__verse_id => db[:refs].select(:verse_id).where(:ref_name => @exclude)) if @exclude
      q
    end

    def each(&block)
      query.each(&block)
    end

    def print(verse_format: nil, body_format: nil, sep: ' ', linesep: "\n", io: $stdout)
      shown = false
      verse_format ||= lambda{ |book, chapter, verse| "#{book}#{sep}#{chapter}:#{verse}" }
      body_format ||= lambda{ |body| body + linesep }
      query.each do |row|
        shown = true
        io.print verse_format[
          row[:book_name],
          row[:verse_chapter],
          row[:verse_number]
        ]
        io.print sep
        io.print body_format[ row[:content_body] ]
      end
      io.puts "Nothing found" unless shown
    end
  end
end