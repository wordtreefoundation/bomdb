module BomDB
  module Models
    class Edition
      def initialize(db)
        @db = db
      end

      # Find an edition and return a hash, or nil if not found
      def find(edition_name_prefix)
        @db[:editions].
          where(Sequel.like(:edition_name, "#{edition_name_prefix}%")).
          or(:edition_year => edition_name_prefix).
          first
      end
    end
  end
end