require 'constellation'
require 'yaml'

module BomDB
  class Config

    Constellation.enhance self

    self.config_file = '.bomdb'
    self.load_from_gems = true
    self.env_params = {
      db_path: 'BOMDB_DB_PATH',
      data_dir: 'BOMDB_DATA_DIR',
    }

    DEFAULT_DATA_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'data'))

    def db_path
      @data.fetch('db_path', File.join(data_dir, db_file))
    end

    def data_dir
      @data.fetch('data_dir', DEFAULT_DATA_DIR)
    end

    private

    def parse_config_file(contents)
      YAML::load(contents)
    end
  end
end