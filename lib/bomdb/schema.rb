require 'set'

module BomDB
  class Schema
    def initialize(db)
      @db = db
    end

    def has_tables?(*table_names)
      Set.new(@db.tables) >= Set.new(table_names)
    end

    def reset(*table_names)
      drop_tables(table_names)
      create_tables(table_names)
    end

    def drop_tables(table_names = nil)
      (table_names || @db.tables).each do |name|
        @db.drop_table(name) if @db.tables.include?(name)
      end
    end

    def create_tables(table_names = nil)
      @db.create_table(:books) do
        primary_key :book_id

        string  :book_name, :unique => true
        string  :book_group
        integer :book_sort
      end if include?(table_names, :books)

      @db.create_table(:verses) do
        primary_key :verse_id
        foreign_key :book_id, :books

        integer :verse_chapter, :null => true
        integer :verse_number,   :null => true
        integer :verse_heading, :null => true

        index [:book_id, :verse_chapter, :verse_number, :verse_heading], :unique => true
      end if include?(table_names, :verses)

      @db.create_table(:versions) do
        primary_key :version_id

        string      :version_name
        integer     :version_year
      end if include?(table_names, :versions)

      @db.create_table(:contents) do
        primary_key :content_id
        foreign_key :version_id, :versions
        foreign_key :verse_id, :verses

        string :content_body

        index [:version_id, :verse_id], :unique => true
      end if include?(table_names, :contents)

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
      end if include?(table_names, :refs)

      @db.create_table(:notes) do
        primary_key :note_id
        foreign_key :verse_id, :verses

        string :note_highlight
        string :note_body
      end if include?(table_names, :notes)
    end

    protected

    def include?(table_names, name)
      table_names.nil? ||
      table_names.map{ |n| n.to_sym }.include?(name.to_sym)
    end
  end
end