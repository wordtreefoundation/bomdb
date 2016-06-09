require 'thor'
require 'bomdb'
require 'colorize'
require 'text_clean'

module BomDB
  module Cli
    class Application < Thor


      desc "version", "show the version of bomdb"
      def version
        puts BomDB::VERSION
      end

      desc "import FILE", "import data from FILE into database, e.g. books.json"
      option :type,    :type => :string, :default => nil,
             :description => "type of data to import, i.e. one of: books, verses, editions, contents, refs"
      option :format,  :type => :string, :default => 'json',
             :description => "format of the data being imported. One of: json, text"
      option :edition, :type => :string, :default => nil,
             :description => "edition of the Book of Mormon in which to import (assumes type=contents) (required when format=text)"
      def import(file)
        type   = (options[:type]   || type_from_file(file)).downcase
        format = (options[:format] || format_from_file(file)).downcase

        importer =
        case type
        when 'books'    then BomDB::Import::Books.new(BomDB.db)
        when 'verses'   then BomDB::Import::Verses.new(BomDB.db)
        when 'editions' then BomDB::Import::Editions.new(BomDB.db)
        when 'contents' then BomDB::Import::Contents.new(BomDB.db, edition_prefix: options[:edition])
        when 'refs'     then BomDB::Import::Refs.new(BomDB.db)
        else
          puts "Unknown import type #{type}"
          exit -1
        end

        begin
          result = importer.import(read(file), format: format)
        rescue JSON::ParserError
          puts "Couldn't parse as JSON. Use '--format=text'?"
          exit -1
        end
        show_result_and_maybe_exit(result)
      end



      desc "export TYPE", "export data from the database, i.e. one of: books, verses, editions, contents"
      option :format, :type => :string,  :default => 'json',
             :description => "format of the data being imported. One of: json, text"
      option :editions, :type => :string, :default => :all,
             :description => "edition(s) of the Book of Mormon to export. Defaults to 'all' editions."
      def export(type)
        format = options[:format].downcase

        exporter =
        case type
        when 'books'    then BomDB::Export::Books.new(BomDB.db)
        when 'verses'   then BomDB::Export::Verses.new(BomDB.db)
        when 'editions' then BomDB::Export::Editions.new(BomDB.db)
        when 'contents' then BomDB::Export::Contents.new(BomDB.db, edition_prefixes: options[:editions])
        # when 'refs'     then BomDB::Export::Refs.new(BomDB.db)
        else
          puts "Unknown import type #{type}"
          exit -1
        end

        result = exporter.export(format: format)
        if result.success?
          puts result.to_s
        else
          show_result_and_maybe_exit(result)
        end
      end



      desc "create", "create a new Book of Mormon database"
      option :file, :type => :string, :default => BomDB.config.db_path,
             :description => "the filepath of the database file on disk"
      option :bare, :type => :boolean, :default => false,
             :description => "create a bare database without any data"
      option :delete, :type => :boolean, :default => false, :aliases => [:y],
             :description => "don't ask for confirmation before overwriting an existing database"
      def create
        db_path = options[:file]

        if File.exist?(db_path) and !options[:delete]
          puts "Database file '#{db_path}' exists. Delete? (y/N) "
          if $stdin.gets.chomp.downcase != "y"
            puts "Exiting..."
            exit -1
          end
          verbing = 'Overwriting'
        else
          verbing = 'Creating'
        end

        puts "#{verbing} database '#{db_path}' ..."
        schema = BomDB::Schema.create(db_path)
        puts "Created the following tables:"
        schema.db.tables.each{ |t| puts "\t#{t}" }

        unless options[:bare]
          puts "Importing books..."
          import('books.json')

          puts "Importing verses..."
          import('verses.json')

          puts "Importing editions..."
          import('editions.json')

          puts "Importing contents..."
          import('contents.json')

          puts "Importing refs..."
          import('refs.json')
        end

        puts "Done."
      end



      desc "show RANGE", "show a RANGE of verses in the Book of Mormon (defaults to 1829 edition)"
      option :verses,  :type => :boolean, :default => true,
             :description => "show book, chapter, verse annotations"
      option :exclude, :type => :string, :aliases => [:x],
             :description => "exclude verses that are references, e.g. Bible-OT references"
      option :"exclude-only-quotations", :type => :boolean, :aliases => [:q],
             :description => "don't exclude verses with references that are non-quotations"
      option :sep,     :type => :string,  :default => " ",
             :description => "separator between annotations and content, defaults to ' '"
      option :linesep, :type => :string,  :default => "\n",
             :description => "separator between verses. Defaults to newline ('\\n')."
      option :color,   :type => :boolean, :default => true,
             :description => "show chapter and verse in color"
      option :"for-alignment", :type => :boolean, :default => false,
             :description => "show output in 'alignment' mode. Useful for debugging 'align' subcommand issues."
      option :clean,   :type => :boolean, :default => false,
             :description => "remove punctuation and normalize text by sentence"
      option :edition, :type => :string, :default => '1829',
             :description => "show verses from a specific edition (see 'editions' command for list)"
      option :search,  :type => :string, :default => nil,
             :description => "show only verses that contain the search term"
      def show(range = nil)
        body_format = nil
        wordsep = options[:sep]
        linesep = options[:linesep]

        if options[:"for-alignment"]
          linesep = " "
          verse_format = verse_format_for_alignment(options[:color])
        elsif options[:clean]
          linesep = " "
          verse_format = lambda{ |b,c,v| '' }
          body_format = lambda do |body|
            TextClean.clean(body)
          end
        else
          if options[:verses]
            if options[:color]
              verse_format = lambda do |b,c,v|
                b.colorize(:yellow) + wordsep + 
                c.to_s.colorize(:green) + ':' + 
                v.to_s.colorize(:light_green)
              end
            else
              verse_format = nil
            end
          else
            verse_format = lambda{ |b,c,v| '' }
          end
        end
        BomDB::Query.new(
          edition: options[:edition],
          range: range,
          search: options[:search],
          exclude: options[:exclude],
          exclude_only_quotations: options[:"exclude-only-quotations"]
        ).print(
          verse_format: verse_format,
          body_format: body_format,
          sep:     wordsep,
          linesep: linesep
        )
      end



      desc "editions", "list available editions of the Book of Mormon"
      option :all, :type => :boolean, :default => false,
             :description => "Show all known editions, including those without content in BomDB"
      option :"show-missing-verses", :type => :boolean, :default => false,
             :description => "Lists missing verses in each edition (useful for fixing import errors)"
      def editions
        BomDB.db[:editions].
          left_outer_join(:contents, :edition_id => :edition_id).
          select_group(:editions__edition_id, :edition_name).
          select_append{ Sequel.as(count(:verse_id), :count) }.
          order(:edition_name).
        each do |r|
          if r[:count] > 0 || options[:all]
            puts "#{r[:count]} verses\t#{r[:edition_name]}"
          end
          if options[:"show-missing-verses"] && r[:count] > 0
            BomDB.db[
              "SELECT b.book_name, v.verse_chapter, v.verse_number " +
              "FROM verses v " +
              "JOIN books b ON v.book_id = b.book_id " +
              "WHERE v.verse_heading IS NULL " +
              "AND v.verse_id NOT IN " +
              "(" +
              " SELECT verse_id FROM contents c " +
              " WHERE c.edition_id = ? " +
              " AND c.verse_id = v.verse_id" +
              ") " +
              "ORDER BY b.book_sort, v.verse_chapter, v.verse_number",
              r[:edition_id]
            ].
            each do |s|
              puts "  #{s[:book_name]} #{s[:verse_chapter]}:#{s[:verse_number]} missing"
            end
          end
        end
      end



      desc "references TYPE", "list reference types or references of TYPE"
      def references(type=nil)
        if type.nil?
          rts = BomDB.db[:refs].
            select_group(:ref_name).
            select_append{ Sequel.as(count(ref_id), :count) }.
            map { |r| "#{r[:ref_name]} (#{r[:count]} refs)" }
          puts rts.join("\n")
        else
          rts = BomDB.db[:refs].
            where(:ref_name => type).
            join(:verses, :verse_id => :verse_id).
            join(:books, :book_id => :book_id).
            map do |r|
              asterisk = r[:ref_is_quotation] ? '*' : ''
              "#{r[:ref_book]} #{r[:ref_chapter]}:#{r[:ref_verse]} => " +
              "#{r[:book_name]} #{r[:verse_chapter]}:#{r[:verse_number]}" +
              "#{asterisk}"
            end
          puts rts.join("\n")
        end
      end



      desc "align FILE EDITION", "give verse annotations from EDITION to a new Book of Mormon text FILE that lacks verse annotations"
      option :dwdiff, :type => :string, :default => "/usr/local/bin/dwdiff",
             :description => "the filepath of the dwdiff binary (shell command)"
      option :'edition-only', :type => :boolean, :default => false,
             :description => "show the alignment-formatted edition output only (useful for debugging)"
      option :'diff-only', :type => :boolean, :default => false,
             :description => "show the dwdiff output only (useful for debugging)"
      def align(file, edition = '1829')
        io = StringIO.new

        BomDB::Query.new(edition: edition).print(
          verse_format: verse_format_for_alignment,
          linesep: ' ',
          io: io
        )
        if options[:'edition-only']
          puts io.string
          exit
        end

        dwdiff = Diff::Dwdiff.new(options[:dwdiff])
        align_str = File.read(file).gsub(/\s\s+/, ' ').gsub(':', '~')
        diff = dwdiff.diff(io.string, align_str)

        if options[:'diff-only']
          puts diff
          exit
        end

        puts Diff::Aligner.parse(diff).gsub('~', ':')
      end


      class Chapter
        attr_reader :wordcount, :book, :chapter
        def initialize(wordcount, book, chapter)
          @wordcount, @book, @chapter = wordcount, book, chapter
        end
      end

      desc "index WORDGROUP", "create an index into the books of the Book of Mormon counting by WORDGROUP"
      def index(wordgroup)
        wordgroup = wordgroup.to_i

        chapters = BomDB::Query.new.chapters.map do |(book, chapter), content|
          Chapter.new(content.split(/\s+/).size, book, chapter)
        end

        total_words = chapters.inject(0){ |sum, ch| sum += ch.wordcount }

        idx = []
        words_so_far = 0
        chapter_index = 0
        j = 0

        (wordgroup..(total_words+wordgroup)).step(wordgroup) do |i|
          while words_so_far < i && chapter_index < chapters.size
            words_so_far += chapters[chapter_index].wordcount
            chapter_index += 1
          end
          c = chapters[chapter_index-1]
          idx << ["#{c.book} #{c.chapter}", j]
          # puts "[#{chapters[chapter_index-1].book} #{chapters[chapter_index-1].chapter},#{j}"
          j += 1
        end

        puts idx.to_json
      end



      private

      def read(file)
        File.read(relative_or_data_file(file))
      end

      def relative_or_data_file(file)
        if File.exist?(file)
          file
        else
          if File.basename(file) == file
            # Try our gem's data directory as a fallback for this file
            File.join(BomDB.config.data_dir, file)
          else
            $stderr.puts "File not found: #{file}"
            exit -1
          end
        end
      end

      def format_from_file(file)
        case File.extname(file).downcase
        when ".txt" then "text"
        when ".json" then "json"
        else
          $stderr.puts "Unable to determine format from file: #{file}"
          exit -1
        end
      end

      def type_from_file(file)
        type = File.basename(file).gsub(/\.(txt|json)$/, '').downcase
      end

      def verse_format_for_alignment
        verse_format = lambda do |book, chapter, verse|
          "[|#{book} #{chapter}:#{verse}|]"
        end
      end

      def show_result_and_maybe_exit(result)
        if result.success?
          $stderr.puts "Success"
        else
          $stderr.puts result.message
          # $stderr.puts "Try again with '--reset'? (NOTE: data may be deleted)"
          exit -1
        end
      end
    end
  end
end
