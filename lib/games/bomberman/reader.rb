require "strscan"

module Games
  module Bomberman
    module Reader
      def self.read(io)
        turns = io.readline.to_i
        score = io.readline.split.map(&:to_i).each_slice(2).map { |a, b| [a, b] }.to_h
        lines = io.readlines.map { |line| line.strip.split(/\s+/) }

        raise unless lines.map(&:size).uniq.size == 1

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
          score: score,
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
          timer = s.scan(/[0-9]+/).to_i
          s.scan(/,/)
          radius = s.scan(/[0-9]+/).to_i
          s.scan(/,/)
          player_ids = s.scan(/[&0-9]+/)&.split("&")&.map(&:to_i) || []

          Entities::Bomb.new(timer, radius, player_ids)
        when 'c'
          Entities::Coin.new(s.scan(/[0-9]+/).to_i)
        when 'm'
          Entities::MoreBombs.new
        when 's'
          Entities::StrongerBombs.new
        when 'e'
          Entities::Explosion.new
        when 'p'
          id = s.scan(/[0-9]+/).to_i
          alive = s.scan(/[ok]/) == "o"

          Entities::Player.new(id, alive)
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
