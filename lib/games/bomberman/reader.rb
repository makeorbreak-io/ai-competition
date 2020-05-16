require "strscan"

module Games
  module Bomberman
    module Reader
      def self.read(io)
        turns = io.readline.to_i
        lines = io.readlines.map { |line| line.strip.split(/\s+/) }

        raise "Different widths: #{lines.map(&:size).uniq}" unless lines.map(&:size).uniq.size == 1

        board_cells = lines.each_with_index.map do |line, i|
          line.each_with_index.map do |cell, j|
            cell2state(cell).map do |agent|
              agent&.positioned_at([i, j])
            end
          end
        end

        State.new(
          width: lines.first.size,
          height: lines.size,
          turn: 0,
          turns_left: turns,
          board: board_cells,
          entities: board_cells.flatten,
        )
      end

      def self.cell2state(cell)
        s = StringScanner.new(cell)
        value = []
        value << scan(s) until s.eos?
        value.compact
      end

      def self.scan(s)
        t = s.scan(/./)

        case t
        when 'b'
          #        timer     range   ids
          s.scan(/([0-9]+),([0-9]+),([&0-9]+)/)

          Entities::Bomb.new(s[1].to_i, s[2].to_i, s[3].split("&").map(&:to_i))
        when 'c'
          Entities::Coin.new(s.scan(/[0-9]+/).to_i)
        when 'm'
          Entities::MoreBombs.new
        when 's'
          Entities::StrongerBombs.new
        when 'e'
          Entities::Explosion.new
        when 'p'
          #         id    alive   points   bombs   range
          s.scan(/([0-9]+)([ok]),([0-9]+),([0-9]+),([0-9]+)/)

          Entities::Player.new(
            s[1].to_i,
            s[2] == "o",
            s[3].to_i,
            s[4].to_i,
            s[5].to_i,
          )
        when 'r'
          Entities::Rock.new(scan(s))
        when 'w'
          Entities::Wall.new
        when '.'
          nil
        else
          raise ArgumentError, "'#{t}' (#{t.class}) not known"
        end
      end
    end
  end
end
