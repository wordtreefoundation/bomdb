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
      let(:db) { BomDB.db }

      context "with data" do
        let(:data) { BomDB::Query.new(exclude: 'Bible-OT') }

        it "queries wherefore/therefore" do
          result = data.books.map do |book,content|
            [ book,
              content.scan(/wherefore/i).size,
              content.scan(/therefore/i).size ]
          end

          expect(result).to match([
            ["1 Nephi", 99, 13],
            ["2 Nephi", 126, 6],
            ["Jacob", 53, 1],
            ["Enos", 6, 0],
            ["Jarom", 3, 0],
            ["Omni", 6, 0],
            ["Words of Mormon", 5, 0],
            ["Mosiah", 0, 122],
            ["Alma", 3, 288],
            ["Helaman", 0, 63],
            ["3 Nephi", 3, 97],
            ["4 Nephi", 0, 5],
            ["Mormon", 0, 22],
            ["Ether", 63, 26],
            ["Moroni", 38, 0]
          ])
        end
      end
    end
  end
end