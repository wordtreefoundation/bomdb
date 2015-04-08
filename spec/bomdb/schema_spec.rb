require_relative '../spec_helper'

describe BomDB::Schema do
  let(:db_path) { File.join(@dir, "test.db") }

  it "has a db accessor" do
    schema = BomDB::Schema.new("test")
    expect(schema.db).to eq("test")
  end

  describe "Schema.create" do
    it "creates a database" do
      BomDB::Schema.create(db_path)
      expect(File.exist?(db_path)).to be_truthy
    end

    it "overwrites existing database" do
      schema = BomDB::Schema.create(db_path)
      expect(File.exist?(db_path)).to be_truthy

      schema.db[:books].insert(book_name: "test")
      expect(schema.db[:books].count).to eq(1)

      schema = BomDB::Schema.create(db_path)
      expect(schema.db[:books].count).to eq(0)
    end
  end
end
