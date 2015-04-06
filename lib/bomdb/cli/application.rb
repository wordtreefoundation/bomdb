require 'thor'
require 'bomdb'

module BomDB
  module Cli
    class Application < Thor
      desc "import TYPE", "import data of TYPE into database, e.g. books"
      option :reset, :type => :boolean, :default => false
      def import(type, file=nil)
        case type.downcase
        when 'books'          
          result = import_books(file, options[:reset])
          show_result_and_maybe_exit(result)
        when 'verses'
          result = import_verses(file, options[:reset])
          show_result_and_maybe_exit(result)
        when 'biblical-refs'
          result = import_biblical_refs(true)
          show_result_and_maybe_exit(result)
        else
          puts "Unknown import type #{type}"
          exit -1
        end
      end

      desc "build", "[delete and re-]build the database"
      option :delete, :type => :boolean, :default => false, :aliases => [:y]
      def build
        dbp = BomDB.config.db_path
        if File.exist?(dbp) and !options[:delete]
          puts "Database file '#{dbp}' exists. Delete? (y/N) "
          if $stdin.gets.chomp.downcase != "y"
            puts "Exiting..."
            exit -1
          end
        end

        # Delete the database
        FileUtils.rm(dbp)

        puts "Importing books..."
        show_result_and_maybe_exit(import_books(nil, true))

        puts "Importing verses..."
        show_result_and_maybe_exit(import_verses(nil, true))

        puts "Importing biblical refs..."
        show_result_and_maybe_exit(import_biblical_refs(true))

      end

      desc "show EDITION RANGE", "show an edition of the Book of Mormon, or a RANGE of verses"
      option :verse,   :type => :boolean, :default => true
      option :exclude, :type => :string, :aliases => [:x]
      option :sep,     :type => :string,  :default => ' '
      option :linesep, :type => :string,  :default => '\n'
      option :"for-alignment", :type => :boolean, :default => false
      def show(edition = '1829', range = nil)
        if options[:"for-alignment"]
          linesep = ' '
          verse_format = lambda do |book, chapter, verse|
            "[|#{book}#{options[:sep]}#{chapter}:#{verse}|]"
          end
          body_format = nil
        else
          linesep = options[:linesep]
          if options[:verse]
            verse_format = nil
          else
            verse_format = lambda{ |b,c,v| '' }
          end
          body_format = nil
        end
        query = BomDB::Query.new(
          edition: edition,
          exclude: options[:exclude]
          # range: range
        )
        query.print(
          verse_format: verse_format,
          body_format: body_format,
          sep:     options[:sep],
          linesep: linesep
        )
      end

      desc "editions", "list available editions of the Book of Mormon"
      # option :available, :type => :boolean, :default => true
      def editions
        eds = BomDB.db[:versions].map do |r|
          [r[:version_year], r[:version_name]].join(' -- ')
        end
        puts eds.join('\n')
      end

      desc "reference-types", "list reference types"
      def reference_types
        rts = BomDB.db[:refs].distinct.select(:ref_name).map do |r|
          r[:ref_name]
        end
        puts rts.join('\n')
      end

      private

      def datafile(file)
        File.join(BomDB.config.data_dir, file)
      end

      def import_books(file, reset = true)
        data = File.read(file || datafile("books.json"))

        import = BomDB::Import::Books.new(BomDB.db)
        import.reset if reset

        import.json(data)
      end

      def import_verses(file, reset = true)
        data = File.read(file || datafile("verses.json"))

        import = BomDB::Import::Verses.new(BomDB.db)
        import.reset if reset

        import.json(data)
      end

      def import_biblical_refs(reset = true)
        import = BomDB::Import::BiblicalRefs.new(BomDB.db)
        import.reset if reset

        import.import
      end

      def show_result_and_maybe_exit(result)
        if !result.success?
          puts result.message
          # if result.error.is_a?(Sequel::UniqueConstraintViolation)
          puts "Try again with '--reset'? (NOTE: data may be deleted)"
          # end
          exit -1
        end
      end
    end
  end
end
