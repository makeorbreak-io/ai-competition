require 'stringio'

module Games
  module Bomberman
    module Writer
      def self.write(state)
        io = StringIO.new

        io.puts state.turns_left

        cells = state.board.map do |row|
          row.map { |agents| cell_to_s(agents) }
        end

        width = cells.transpose.map { |column| column.map(&:size).max }

        cells.each do |row|
          io.puts row.each_with_index.map { |cell, i| cell.ljust(width[i]) }.join(" ")
        end

        io.string
      end

      def self.cell_to_s(cell)
        return "." if cell.empty?
        cell.map(&method(:entity_to_s)).sort.join
      end

      def self.entity_to_s(agent)
        case agent
        when Entities::Bomb
          "b#{agent.timer},#{agent.range},#{agent.player.sort.join("&")}"
        when Entities::Coin
          "c#{agent.points}"
        when Entities::MoreBombs
          "m"
        when Entities::StrongerBombs
          "s"
        when Entities::Explosion
          "e"
        when Entities::Player
          "p#{agent.id}#{agent.alive ? "o" : "k"},#{agent.points},#{agent.simultaneous_bombs},#{agent.bomb_range}"
        when Entities::Rock
          "r#{entity_to_s(agent.reward)}"
        when Entities::Wall
          "w"
        when nil
          "."
        end
      end
    end
  end
end
