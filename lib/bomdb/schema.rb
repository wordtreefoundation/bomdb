require 'set'
require 'sequel'
require 'fileutils'

module BomDB
  class Schema
    attr_reader :db

    def initialize(db)
      @db = db
    end

    # create a new database
    def self.create(db_path, tables = :all)
      FileUtils.rm(db_path) if File.exist?(db_path)
      new(Sequel.sqlite(db_path)).create_tables(tables)
    end

    def has_tables?(tables)
      Set.new(@db.tables) >= Set.new(tables)
    end

    def create_tables(tables = :all)
      @db.create_table(:books) do
        primary_key :book_id

        string  :book_name, :unique => true
        string  :book_group
        integer :book_sort
      end if include?(tables, :books)

      @db.create_table(:verses) do
        primary_key :verse_id
        foreign_key :book_id, :books

        integer :verse_chapter, :null => true
        integer :verse_number,  :null => true
        integer :verse_heading, :null => true

        index [:book_id, :verse_chapter, :verse_number, :verse_heading], :unique => true
      end if include?(tables, :verses)

      @db.create_table(:editions) do
        primary_key :edition_id

        integer     :edition_year
        string      :edition_name, :unique => true
      end if include?(tables, :editions)

      @db.create_table(:contents) do
        primary_key :content_id
        foreign_key :edition_id, :editions
        foreign_key :verse_id, :verses

        string :content_body

        index [:edition_id, :verse_id], :unique => true
      end if include?(tables, :contents)

      @db.create_table(:refs) do
        primary_key :ref_id
        foreign_key :verse_id, :verses

        string  :ref_name

        string  :ref_book
        integer :ref_chapter
        integer :ref_verse
        integer :ref_page_start
        integer :ref_page_end
        boolean :ref_is_parallel
        boolean :ref_is_quotation
      end if include?(tables, :refs)

      @db.create_table(:notes) do
        primary_key :note_id
        foreign_key :verse_id, :verses

        string :note_highlight
        string :note_body
      end if include?(tables, :notes)

      self
    end

    protected

    def include?(tables, name)
      tables == :all || tables.map{ |n| n.to_sym }.include?(name.to_sym)
    end
  end
end