module BomDB
  module Import
    class BiblicalRefs < Import::Base

      def reset
        schema.reset(:refs)
      end

      def ref(
            ref_name: "Bible",
            book:, ref_book:,
            chapter:, ref_chapter:,
            verse: nil, ref_verse: nil,
            is_parallel: false, is_quotation: false)
        verses = @db[:verses].join(:books, :book_id => :book_id)
        verses.where!(:book_name => book, :verse_chapter => chapter, :verse_heading => nil)
        verses.where!(:verse_number => verse) if verse

        verses.each do |row|
          ref_id = @db[:refs].insert(
            ref_name: ref_name,
            verse_id: row[:verse_id],
            ref_book: ref_book,
            ref_chapter: ref_chapter,
            ref_verse: ref_verse || row[:verse_number],
            ref_is_parallel: is_parallel,
            ref_is_quotation: is_quotation
          )
          # puts ref_id
        end
      end

      def import
        if !schema.has_tables?(:refs)
          return Import::Result.new(
            success: false,
            error: "Database table 'refs' not present."
          )
        end

        begin
          # 2 Nephi 12-24 quotes Isaiah 2-14
          (12..24).each do |chapter|
            ref(ref_name: "Bible-OT", is_quotation: true,
              book: '2 Nephi', chapter: chapter,
              ref_book: 'Isaiah', ref_chapter: chapter - 10)
          end

          # 2 Nephi 27 quotes Isaiah 29
          ref(ref_name: "Bible-OT", is_quotation: true,
            book: '2 Nephi', chapter: 27, 
            ref_book: 'Isaiah', ref_chapter: 29)

          # 1 Nephi 20–21 quotes Isaiah 48-49
          ref(ref_name: "Bible-OT", is_quotation: true,
            book: '1 Nephi', chapter: 20, 
            ref_book: 'Isaiah', ref_chapter: 48)
          ref(ref_name: "Bible-OT", is_quotation: true,
            book: '1 Nephi', chapter: 21,
            ref_book: 'Isaiah', ref_chapter: 49)

          # 2 Nephi 7–8 quotes Isaiah 50–51
          ref(ref_name: "Bible-OT", is_quotation: true,
            book: '2 Nephi', chapter: 7,
            ref_book: 'Isaiah', ref_chapter: 50)
          ref(ref_name: "Bible-OT", is_quotation: true,
            book: '2 Nephi', chapter: 8,
            ref_book: 'Isaiah', ref_chapter: 51)

          # 3 Nephi 20 quotes Isaiah 52
          ref(ref_name: "Bible-OT", is_quotation: true,
            book: '3 Nephi', chapter: 20,
            ref_book: 'Isaiah', ref_chapter: 52)

          # Mosiah 14 quotes Isaiah 53
          ref(ref_name: "Bible-OT", is_quotation: true,
            book: 'Mosiah', chapter: 14,
            ref_book: 'Isaiah', ref_chapter: 53)

          # 3 Nephi 22 quotes Isaiah 54
          ref(ref_name: "Bible-OT", is_quotation: true,
            book: '3 Nephi', chapter: 22, 
            ref_book: 'Isaiah', ref_chapter: 54)

          # 2 Nephi 29:2 parallels Isaiah 5:26
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 29, verse: 2,
            ref_book: 'Isaiah', ref_chapter: 5, ref_verse: 26)

          # 2 Nephi 28:32 quotes Isaiah 9:12-13
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 28, verse: 32,
            ref_book: 'Isaiah', ref_chapter: 9, ref_verse: 12)

          # 2 Nephi 30:9 quotes Isaiah 11:4
          ref(ref_name: "Bible-OT", is_quotation: true,
            book: '2 Nephi', chapter: 30, verse: 9,
            ref_book: 'Isaiah', ref_chapter: 11, ref_verse: 4)

          # 2 Nephi 30:11-15 quotes Isaiah 11:5-9
          (11..15).each do |verse|
            ref(ref_name: "Bible-OT", is_quotation: true,
              book: '2 Nephi', chapter: 30, verse: verse,
              ref_book: 'Isaiah', ref_chapter: 11, ref_verse: verse - 6)
          end

          # 2 Nephi 25:17; 29:1; compare 25:11 parallels Isaiah 11:11
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 25, verse: 17,
            ref_book: 'Isaiah', ref_chapter: 11, ref_verse: 11)

          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 29, verse: 1,
            ref_book: 'Isaiah', ref_chapter: 11, ref_verse: 11)

          # 2 Nephi 28:7-8 parallels Isaiah 22:13
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 28, verse: 7,
            ref_book: 'Isaiah', ref_chapter: 22, ref_verse: 13)

          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 28, verse: 8,
            ref_book: 'Isaiah', ref_chapter: 22, ref_verse: 13)

          # 2 Nephi 26:15 parallels Isaiah 25:12
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 26, verse: 15,
            ref_book: 'Isaiah', ref_chapter: 25, ref_verse: 12)

          # 2 Nephi 28:30 parallels Isaiah 28:10, 13
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 28, verse: 30,
            ref_book: 'Isaiah', ref_chapter: 28, ref_verse: 10)

          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 28, verse: 30,
            ref_book: 'Isaiah', ref_chapter: 28, ref_verse: 13)

          # 2 Nephi 26:15-16 parallels Isaiah 29:3-4
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 26, verse: 15,
            ref_book: 'Isaiah', ref_chapter: 29, ref_verse: 3)

          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 26, verse: 16,
            ref_book: 'Isaiah', ref_chapter: 29, ref_verse: 4)

          # 2 Nephi 26:18 parallels Isaiah 29:5
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 26, verse: 18,
            ref_book: 'Isaiah', ref_chapter: 29, ref_verse: 5)

          # 2 Nephi 6:15 parallels Isaiah 29:6
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 6, verse: 15,
            ref_book: 'Isaiah', ref_chapter: 29, ref_verse: 6)

          # 2 Nephi 27:2-5 parallels Isaiah 29:6-10
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 27, verse: 2,
            ref_book: 'Isaiah', ref_chapter: 29, ref_verse: 6)

          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 27, verse: 3,
            ref_book: 'Isaiah', ref_chapter: 29, ref_verse: 7)

          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 27, verse: 3,
            ref_book: 'Isaiah', ref_chapter: 29, ref_verse: 8)

          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 27, verse: 4,
            ref_book: 'Isaiah', ref_chapter: 29, ref_verse: 9)

          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 27, verse: 5,
            ref_book: 'Isaiah', ref_chapter: 29, ref_verse: 10)

          # 1 Nephi 14:7; 1 Nephi 22:8; 2 Nephi 29:1 weakly parallel Isaiah 29:14
          # 2 Nephi 25:17 parallels Isaiah 29:14
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 25, verse: 17,
            ref_book: 'Isaiah', ref_chapter: 29, ref_verse: 14)

          # 2 Nephi 28:9 parallels Isaiah 29:15
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 28, verse: 9,
            ref_book: 'Isaiah', ref_chapter: 29, ref_verse: 15)

          # 1 Nephi 10:8 parallels Isaiah 40:3
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '1 Nephi', chapter: 10, verse: 8,
            ref_book: 'Isaiah', ref_chapter: 40, ref_verse: 3)

          # 1 Nephi 17:36 parallels Isaiah 45:18
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '1 Nephi', chapter: 17, verse: 36,
            ref_book: 'Isaiah', ref_chapter: 45, ref_verse: 18)

          # Mosiah 27:31 parallels Isaiah 45:23
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: 'Mosiah', chapter: 27, verse: 31,
            ref_book: 'Isaiah', ref_chapter: 45, ref_verse: 23)

          # 1 Nephi 22:6, 1 Nephi 22:8, 2 Nephi 6:6 parallel Isaiah 49:22
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '1 Nephi', chapter: 22, verse: 6,
            ref_book: 'Isaiah', ref_chapter: 49, ref_verse: 22)

          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '1 Nephi', chapter: 22, verse: 8,
            ref_book: 'Isaiah', ref_chapter: 49, ref_verse: 22)

          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 6, verse: 6,
            ref_book: 'Isaiah', ref_chapter: 49, ref_verse: 22)

          # 2 Nephi 6:7; 2 Nephi 10:9 parallel Isaiah 49:23
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 6, verse: 7,
            ref_book: 'Isaiah', ref_chapter: 49, ref_verse: 23)

          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 10, verse: 9,
            ref_book: 'Isaiah', ref_chapter: 49, ref_verse: 23)

          # 2 Nephi 6:16-18 quotes Isaiah 49:24-26
          (16..18).each do |verse|
            ref(ref_name: "Bible-OT", is_quotation: true,
              book: '2 Nephi', chapter: 6, verse: verse,
              ref_book: 'Isaiah', ref_chapter: 49, ref_verse: verse + 8)
          end

          # Moroni 10:31 parallels Isaiah 52:1
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: 'Moroni', chapter: 10, verse: 31,
            ref_book: 'Isaiah', ref_chapter: 52, ref_verse: 1)

          # 2 Nephi 8:24-25 quotes Isaiah 52:1-2
          (24..25).each do |verse|
            ref(ref_name: "Bible-OT", is_quotation: true,
              book: '2 Nephi', chapter: 8, verse: verse,
              ref_book: 'Isaiah', ref_chapter: 52, ref_verse: verse - 23)
          end

          # 1 Nephi 13:37; Mosiah 15:14-18; 27:37 parallels Isaiah 52:7
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '1 Nephi', chapter: 13, verse: 37,
            ref_book: 'Isaiah', ref_chapter: 52, ref_verse: 7)

          (14..18).each do |verse|
            # All 5 verses repeat a reference to Isaiah 52:7
            ref(ref_name: "Bible-OT", is_parallel: true,
              book: 'Mosiah', chapter: 15, verse: verse,
              ref_book: 'Isaiah', ref_chapter: 52, ref_verse: 7)
          end

          ref(ref_name: "Bible-OT", is_parallel: true,
            book: 'Mosiah', chapter: 27, verse: 37,
            ref_book: 'Isaiah', ref_chapter: 52, ref_verse: 7)

          # Mosiah 12:21-24 quotes Isaiah 52:7-10
          (21..24).each do |verse|
            ref(ref_name: "Bible-OT", is_quotation: true,
              book: 'Mosiah', chapter: 12, verse: verse,
              ref_book: 'Isaiah', ref_chapter: 52, ref_verse: verse - 14)
          end

          # Mosiah 15:29-31; 3 Nephi 16:18-20 quote Isaiah 52:8-10
          (29..31).each do |verse|
            ref(ref_name: "Bible-OT", is_quotation: true,
              book: 'Mosiah', chapter: 15, verse: verse,
              ref_book: 'Isaiah', ref_chapter: 52, ref_verse: verse - 21)
          end

          (18..20).each do |verse|
            # Same Isaiah quote as above, but now in 3 Nephi
            ref(ref_name: "Bible-OT", is_quotation: true,
              book: '3 Nephi', chapter: 16, verse: verse,
              ref_book: 'Isaiah', ref_chapter: 52, ref_verse: verse - 10)
          end

          # 3 Nephi 20:32, 34-35 parallels Isaiah 52:8-10
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '3 Nephi', chapter: 20, verse: 32,
            ref_book: 'Isaiah', ref_chapter: 52, ref_verse: 8)

          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '3 Nephi', chapter: 20, verse: 34,
            ref_book: 'Isaiah', ref_chapter: 52, ref_verse: 9)

          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '3 Nephi', chapter: 20, verse: 35,
            ref_book: 'Isaiah', ref_chapter: 52, ref_verse: 10)

          # 1 Nephi 22:10, 11 each parallel Isaiah 52:10
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '1 Nephi', chapter: 22, verse: 10,
            ref_book: 'Isaiah', ref_chapter: 52, ref_verse: 10)

          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '1 Nephi', chapter: 22, verse: 11,
            ref_book: 'Isaiah', ref_chapter: 52, ref_verse: 10)

          # 3 Nephi 21:29 parallels Isaiah 52:12
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '3 Nephi', chapter: 21, verse: 29,
            ref_book: 'Isaiah', ref_chapter: 52, ref_verse: 12)

          # 3 Nephi 21:8 parallels Isaiah 52:15
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '3 Nephi', chapter: 21, verse: 8,
            ref_book: 'Isaiah', ref_chapter: 52, ref_verse: 15)

          # Mosiah 15:10 parallels Isaiah 53:8,10
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: 'Mosiah', chapter: 15, verse: 10,
            ref_book: 'Isaiah', ref_chapter: 53, ref_verse: 8)

          ref(ref_name: "Bible-OT", is_parallel: true,
            book: 'Mosiah', chapter: 15, verse: 10,
            ref_book: 'Isaiah', ref_chapter: 53, ref_verse: 10)

          # Moroni 10:31 parallels Isaiah 54:2
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: 'Moroni', chapter: 10, verse: 31,
            ref_book: 'Isaiah', ref_chapter: 54, ref_verse: 2)

          # 2 Nephi 26:25 parallels Isaiah 55:1
          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 26, verse: 25,
            ref_book: 'Isaiah', ref_chapter: 55, ref_verse: 1)

          # 2 Nephi 9:50-51 quotes/parallels Isaiah 55:1-2
          ref(ref_name: "Bible-OT", is_quotation: true,
            book: '2 Nephi', chapter: 9, verse: 50,
            ref_book: 'Isaiah', ref_chapter: 55, ref_verse: 1)

          ref(ref_name: "Bible-OT", is_parallel: true,
            book: '2 Nephi', chapter: 9, verse: 51,
            ref_book: 'Isaiah', ref_chapter: 55, ref_verse: 2)
        rescue => e
          Import::Result.new(success: false, error: e)
        end
        Import::Result.new(success: true)
      end

      def list
        @db[
          "SELECT book_name, verse_chapter, verse_number, ref_name, ref_book, ref_chapter, ref_verse " +
          "FROM `verses` v " +
          "JOIN `books` b ON b.book_id = v.book_id " +
          "JOIN `refs` r ON r.verse_id = v.verse_id " +
          "ORDER BY ref_book, ref_chapter, ref_verse"
        ].map(&:inspect).join("\n")
      end
    end
  end
end
