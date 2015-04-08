require_relative '../spec_helper'
require 'fileutils'
require 'tmpdir'

describe BomDB::Query do
  context "with config" do
    let(:data_dir) { Dir.mktmpdir('bomdb-test') }
    let(:config) { BomDB::Config.new(data_dir: data_dir) }

    after do
      FileUtils.remove_entry_secure data_dir
    end

    context "with schema" do
      before do
        BomDB::Schema.create_tables(BomDB.db)
      end

      context "with data" do
        # let(:book_id) { BomDB.db[:books].insert(book_name: "1 Nephi") }
        # let(:verse1) { BomDB.db[:verses].insert(book_id: book_id, verse_chapter: 1, verse_number: 1) }
        # let(:verse2) { BomDB.db[:verses].insert(book_id: book_id, verse_chapter: 1, verse_number: 2) }
        # let(:edition1) { BomDB.db[:editions].insert() }
      end
    end
  end
end