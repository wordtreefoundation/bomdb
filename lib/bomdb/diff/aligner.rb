require 'strscan'

module BomDB
  module Diff
    class Aligner
      DIFF_RE = /\{(\+|\-)(.+?)\1\}/
      INSERT_RE = /\{\+(.+?)\+\}/
      VERSE_RE = /\[\|([^\]]+)\|\]/

      def self.parse_verse_heading(scanner, deletion, verse_match)
        # the text of the verse, e.g. "1 Nephi 1:1"
        verse = verse_match[1]

        # the range of the verse capture, e.g. [2, 17] from ". [|1 Nephi 1:1|]Yea"
        verse_capture_slice = Range.new(*verse_match.offset(0), true)

        # the deletion without the verse, e.g. ". Yea"
        deletion_without_verse = deletion.clone
        deletion_without_verse.slice!(verse_capture_slice)

        # if there's an insertion immediately following...
        if scanner.scan(INSERT_RE)
          insertion = scanner.matched.match(INSERT_RE)[1]
          insert_pos = verse_match.offset(0).first

          # if the match, without the verse heading, is the same size as its
          # substitution, then concat the pre_match, add the verse heading, and
          # concat the post_match
          if insertion.size > insert_pos
            insertion[0...insert_pos] + "\n" + verse + insertion[(insert_pos-1)..-1]
          else
            insertion[0...insert_pos] + "\n" + verse
          end
        else
          "\n" + verse
        end
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
              inner = diff_match[2]
              # the only deletions we care about are those with verse headings inside them
              if verse_match = VERSE_RE.match(inner)
                output << parse_verse_heading(scanner, inner, verse_match)
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

        return output
      end
    end
  end
end
