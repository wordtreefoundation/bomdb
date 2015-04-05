require_relative '../spec_helper'

# Temporarily set env during block
def set_env(dict = {}, &block)
  restore = {}
  dict.each_pair{ |k,v| restore[k.to_s] = ENV[k.to_s]; ENV[k.to_s] = v }
  block.call
  restore.each_pair{ |k,v| ENV[k.to_s] = v }
end

describe BomDB::Config do
  let(:config) { BomDB::Config.new(data_dir: '/tmp') }

  it "reads ENV vars" do
    set_env(BOMDB_DB_PATH: '/tmp/test') do
      expect(BomDB::Config.new.db_path).to eq('/tmp/test')
    end
  end

  it "loads config from .bomdb" do
    expect(config.db_file).to eq("book_of_mormon.db")
  end

  it "combines data_dir to make db_path" do
    expect(config.db_path).to eq("/tmp/book_of_mormon.db")
  end
end