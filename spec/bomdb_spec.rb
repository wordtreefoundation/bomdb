require_relative 'spec_helper'
require 'tmpdir'

describe BomDB do
  it "has a version" do
    expect(BomDB::VERSION).to be_a(String)
  end

  it "has configuration" do
    expect(BomDB.config).to be_a(BomDB::Config)
  end

  context "with db path" do
    let(:path) { File.join(@dir, "bom.db") }
    before { @dir = Dir.mktmpdir }
    after { FileUtils.remove_entry_secure @dir }

    it "connects to sqlite db" do
      db = BomDB.db(path)
      expect(db).to be_a(Sequel::SQLite::Database)
    end

    it "creates a database file" do
      db = BomDB.db(path)
      db.create_table(:test) { primary_key :id }
      expect(File.exist?(path)).to be_truthy
    end
  end

end