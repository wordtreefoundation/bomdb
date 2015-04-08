require 'rspec'
require 'byebug'
require 'tmpdir'

require_relative '../lib/bomdb'

RSpec.configure do |c|
  c.before(:all) do
    @dir = Dir.mktmpdir("bomdb-test-")
  end

  c.after(:all) do
    FileUtils.remove_entry_secure @dir
  end
end