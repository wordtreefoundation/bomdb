require 'sequel'

dbfile = ARGV.first || "book_of_mormon.db"

module BomDB

  extend self

  def db(dbfile = config.db_path)
    Sequel.sqlite(dbfile)
  end

  def config
    @config ||= BomDB::Config.new
  end
end

require 'byebug'

require 'bomdb/version'
require 'bomdb/config'
require 'bomdb/schema'
require 'bomdb/query'

require 'bomdb/diff/dwdiff'
require 'bomdb/diff/aligner'

require 'bomdb/import/base'
require 'bomdb/import/result'
require 'bomdb/import/books'
require 'bomdb/import/verses'
require 'bomdb/import/editions'
require 'bomdb/import/contents'
require 'bomdb/import/refs'

require 'bomdb/export/base'
require 'bomdb/export/result'
require 'bomdb/export/books'
require 'bomdb/export/verses'