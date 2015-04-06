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
require 'bomdb/import/biblical_refs'
