module BomDB
  module Export
    class Verses
      def self.each(&block)
        
        BomDB::Query.new(
          edition: edition,
          exclude: options[:exclude]
          # range: range
        ).print(
          verse_format: verse_format,
          body_format: body_format,
          sep:     options[:sep],
          linesep: linesep
        )
      end
    end
  end
end