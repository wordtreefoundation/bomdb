require 'strscan'
require 'damerau-levenshtein'

module BomDB
  module Diff
    class Aligner
      DIFF_RE = /\{(\+|\-)(.+?)\1\}/
      INSERT_RE = /\{\+(.+?)\+\}/
      WS_INSERT_RE = /\s?\{\+(.+?)\+\}/
      VERSE_RE = /\[\|([^\]]+)\|\]/

      def self.parse_verse_heading(verse_match, deletion, insertion = nil)
        # the text of the verse, e.g. "1 Nephi 1:1"
        verse = verse_match[1]
        before = after = ''

        # if there's an insertion immediately following...
        if insertion
          # we can assume split will succeed, because the verse was matched
          del_before, del_after = deletion.split(verse_match[0], 2)

          del_before.strip!
          del_after.strip!

          if del_before.empty? && del_after.empty?
            # do nothing
          elsif del_before.empty?
            # the entire insertion goes after the verse heading
            after = insertion.chomp
          elsif del_after.empty?
            # the entire insertion goes before the verse heading
            before = insertion.chomp
          else
            # we have to use some heuristics to figure out where to split
            # the insertion.

            candidates = (0..(insertion.size-1)).map do |i|
              d1 = DamerauLevenshtein.distance(del_before, insertion[0..i])
              d2 = DamerauLevenshtein.distance(del_after, insertion[(i + 1)..-1])
              d3 = insertion[i] == ' ' ? 1 : 0
              [ d1 + d2 + d3, insertion[0..i].chomp, insertion[(i + 1)..-1].chomp ]
            end.sort_by{ |a| a.first }
            if candidates.empty?
              raise "Unable to find candidate split for #{del_before.inspect}, #{del_after.inspect} on #{insertion.inspect}"
            end

            score, before, after = candidates.first
          end
        end
        [before, verse, after]
      end

      def self.parse(diff_text)
        scanner = StringScanner.new(diff_text)

        output = ""

        last_pos = 0
        while !scanner.eos?
          if scanner.scan_until(DIFF_RE)
            output << scanner.pre_match[last_pos..-1]
            last_pos = scanner.pos
            
            diff_match = DIFF_RE.match(scanner.matched)
            case diff_match[1]
            when '-' then # this is a deletion

              delete_inner = diff_match[2] # e.g. ", [|1 Nephi 1:1|] I"
              # see if there's a verse heading in delete_inner
              verse_match = VERSE_RE.match(delete_inner)

              # the only deletions we care about are those with verse headings inside them
              if verse_match
                if scanner.scan(WS_INSERT_RE)
                  ws_insert_match = WS_INSERT_RE.match(scanner.matched)
                  insert_inner = ws_insert_match[1]
                else
                  insert_inner = nil
                end
                before, verse, after = parse_verse_heading(verse_match, delete_inner, insert_inner)
                output << before + "\n" + verse
                output << " " + after
                last_pos = scanner.pos
              end
            when '+' then # this is an insertion
              output << diff_match[2]
            end
          else
            output << scanner.rest
            break
          end
        end

        return output.gsub(/  +/, ' ').gsub(/ +$/, '')
      end
    end
  end
end
