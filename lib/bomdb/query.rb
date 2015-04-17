require 'bomdb/models/edition'

module BomDB
  class Query
    def initialize(edition: 1829, range: nil, exclude: nil, headings: false)
      @edition = edition
      @range = range
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
      if @range
        pericope = Mericope.new(@range)
        pairs = pericope.ranges.map{ |r| [:verse_range_id, r] }
        q.where!(Sequel::SQL::BooleanExpression.from_value_pairs(pairs, :OR))
      end
      if @exclude
        excluded_verse_ids = db[:refs].select(:verse_id).
          where(:ref_name => @exclude.split(/\s*,\s*/))
        q.exclude!(:verses__verse_id => excluded_verse_ids)
      end
      q
    end

    def each(&block)
      query.each(&block)
    end

    def chapters
      groups = query.all.group_by do |x|
        [x[:book_name], x[:verse_chapter]]
      end
      Enumerator.new(groups.size) do |y|
        groups.each do |heading, rows|
          content = rows.map{ |r| r[:content_body] }.join(" ")
          y.yield(heading, content)
        end
      end
    end

    def books
      groups = query.all.group_by{ |x| x[:book_name] }
      Enumerator.new(groups.size) do |y|
        groups.each do |heading, rows|
          content = rows.map{ |r| r[:content_body] }.join(" ")
          y.yield(heading, content)
        end
      end
    end

    def wordgroups(wordcount)
      content = query.all.map{ |r| r[:content_body] }.join(" ")
      groups = content.scan(/[^ ]+/).each_slice(wordcount).map{ |w| w.join(" ") }
      Enumerator.new(groups.size) do |y|
        groups.each do |g|
          y.yield(g)
        end
      end
    end

    def print(verse_format: nil, body_format: nil, sep: ' ', linesep: "\n", io: $stdout)
      shown = false
      verse_format ||= lambda{ |book, chapter, verse| "#{book}#{sep}#{chapter}:#{verse}" }
      body_format ||= lambda{ |body| body + linesep }
      query.each do |row|
        shown = true
        verse = verse_format[
          row[:book_name],
          row[:verse_chapter],
          row[:verse_number]
        ]
        unless verse.empty?
          io.print verse
          io.print sep
        end
        begin
          io.print body_format[ row[:content_body] ]
        rescue TypeError
          next
        end
      end
      io.puts "Nothing shown" unless shown
    end
  end
end