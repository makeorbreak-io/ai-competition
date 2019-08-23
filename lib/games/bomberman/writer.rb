require 'stringio'

module Games
  module Bomberman
    module Writer
      def self.write(state)
        io = StringIO.new

        io.puts state.turns_left
        io.puts state.score.to_a.join(" ")

        cells = state.board.map do |row|
          row.map { |agents| state2cell(agents) }
        end

        width = cells.transpose.map { |column| column.map(&:size).max }

        cells.each do |row|
          io.puts row.each_with_index.map { |cell, i| cell.ljust(width[i]) }.join(" ")
        end

        io.string
      end

      def self.state2cell(cell)
        return "." if cell.empty?
        cell.map(&method(:nacs)).sort.join
      end

      def self.nacs(agent)
        case agent
        when Entities::Bomb
          "b#{agent.timer},#{agent.radius},#{agent.player.sort.join("&")}"
        when Entities::Coin
          "c#{agent.points}"
        when Entities::MoreBombs
          "m"
        when Entities::StrongerBombs
          "s"
        when Entities::Explosion
          "e"
        when Entities::Player
          "p#{agent.id}#{agent.alive ? "o" : "k"}"
        when Entities::Rock
          "r#{nacs(agent.reward)}"
        when Entities::Wall
          "w"
        when nil
          "."
        end
      end
    end
  end
end
