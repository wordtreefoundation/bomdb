require 'thor'
require 'bomdb'
require 'colorize'

module BomDB
  module Cli
    class Application < Thor



      desc "import FILE", "import data from FILE into database, e.g. books.json"
      option :type,   :type => :string,  :default => nil
      option :format, :type => :string,  :default => 'json'
      def import(file)
        type   = (options[:type]   || type_from_file(file)).downcase
        format = (options[:format] || format_from_file(file)).downcase

        importer =
        case type
        when 'books'    then BomDB::Import::Books.new(BomDB.db)
        when 'verses'   then BomDB::Import::Verses.new(BomDB.db)
        when 'editions' then BomDB::Import::Editions.new(BomDB.db)
        when 'contents' then BomDB::Import::Contents.new(BomDB.db)
        when 'refs'     then BomDB::Import::Refs.new(BomDB.db)
        else
          puts "Unknown import type #{type}"
          exit -1
        end

        result = importer.import(read(file), format: format)
        show_result_and_maybe_exit(result)
      end



      desc "export TYPE", "export data from the database, e.g. books"
      option :format, :type => :string,  :default => 'json'
      option :editions, :type => :string, :default => :all
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



      desc "show EDITION RANGE", "show an edition of the Book of Mormon, or a RANGE of verses"
      option :verse,   :type => :boolean, :default => true,
             :description => "show book, chapter, verse annotations"
      option :exclude, :type => :string, :aliases => [:x],
             :description => "exclude verses that are references, e.g. Bible-OT references"
      option :sep,     :type => :string,  :default => " ",
             :description => "separator between annotations and content, defaults to ' '"
      option :linesep, :type => :string,  :default => "\n",
             :description => "separator between verses. Defaults to newline ('\\n')."
      option :color,   :type => :boolean, :default => true,
             :description => "show chapter and verse in color"
      option :"for-alignment", :type => :boolean, :default => false,
             :description => "show output in 'alignment' mode. Useful for debugging 'align' subcommand issues."
      def show(edition = '1829', range = nil)
        body_format = nil
        if options[:"for-alignment"]
          linesep = " "
          verse_format = verse_format_for_alignment(options[:color])
        else
          linesep = options[:linesep]
          if options[:verse]
            if options[:color]
              verse_format = lambda{ |b,c,v| b.colorize(:yellow) + ' ' + 
                                             c.to_s.colorize(:green) + ':' + 
                                             v.to_s.colorize(:light_green) }
            else
              verse_format = nil
            end
          else
            verse_format = lambda{ |b,c,v| '' }
          end
        end
        BomDB::Query.new(
          edition: edition,
          exclude: options[:exclude]
          # range: range
        ).print(
          verse_format: verse_format,
          body_format: body_format,
          sep:     options[:sep],
          linesep: linesep
        )
      end



      desc "editions", "list available editions of the Book of Mormon"
      option :all, :type => :boolean, :default => false
      def editions
        eds = BomDB.db[:editions].
          left_outer_join(:contents, :edition_id => :edition_id).
          select_group(:edition_name).
          select_append{ Sequel.as(count(:verse_id), :count) }.
          order(:edition_name).
          map { |r| "#{r[:count]} verses\t#{r[:edition_name]}" }
        puts eds.join("\n")
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
          rts = BomDB.db[:refs].where(:ref_name => type).
            map{ |r| "#{r[:ref_book]} #{r[:ref_chapter]}:#{r[:ref_verse]}" }
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
        diff = dwdiff.diff(io.string, File.read(file))

        if options[:'diff-only']
          puts diff
          exit
        end

        puts Diff::Aligner.parse(diff)
      end



      private

      def datafile(file)
        
      end

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
