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

      # Returns an edition_id, either found in the db, or created as necessary
      def find_or_create(year, name)
        found = @db[:editions].where(edition_year: year, edition_name: name).first
        return found[:edition_id] if found
        @db[:editions].insert(
          edition_year: year,
          edition_name: name
        )
      end
    end
  end
end