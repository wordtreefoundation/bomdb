require 'tmpdir'

module BomDB
  module Diff
    # This wraps the command-line tool, dwdiff
    # See http://linux.die.net/man/1/dwdiff
    class Dwdiff
      def initialize(bin = '/usr/local/bin/dwdiff')
        @bin = bin
      end

      def diff(str1, str2)
        Dir.mktmpdir("bomdb") do |dir|
          file1 = File.join(dir, "file1.txt")
          file2 = File.join(dir, "file2.txt")
          File.open(file1, "w"){ |f1| f1.write(str1) }
          File.open(file2, "w"){ |f2| f2.write(str2) }
          # -w : start-delete marker, {-
          # -x : end-delete marker,   -}
          # -y : start-insert marker, {+
          # -z : end-insert marker,   +}
          # -P : use punctuation characters as delimiters
          `#{@bin} -w'{-' -x'-}' -y'{+' -z'+}' -P #{file1} #{file2}`
        end
      end
    end
  end
end