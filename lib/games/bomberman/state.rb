require "json"

module Games
  module Bomberman
    class State < Struct.new(
      :width,
      :height,
      :turn,
      :turns_left,
      :board,
      :score,
      keyword_init: true
    )
      def self.parse(io)
        Reader.read(io)
      end

      def to_s
        Writer.write(self)
      end

      def to_player(id:)
        mask_player_id = -> (player_id) { id == 0 ? player_id : id - player_id  }

        {
          self: id,
          width: width,
          height: height,
          turn: turn,
          turns_left: turns_left,
          score: score.transform_keys(&mask_player_id),
          board: board.map { |row| row.map { |cell| cell.map { |entity|
            case entity
            when Entities::Rock
              { "type": "rock" }
            when Entities::Wall
              { "type": "wall" }
            when Entities::Coin
              { "type": "coin", points: entity.points }
            when Entities::Player
              { "type": "player", id: mask_player_id[entity.id], alive: entity.alive }
            when Entities::Bomb
              { "type": "bomb", timer: entity.timer, radius: entity.radius, player: mask_player_id[entity.player] }
            when Entities::Explosion
              { "type": "explosion" }
            end
          } }}
        }.then(&JSON.method(:dump)).then(&JSON.method(:load))
      end

      def player_ids
        players.map(&:id)
      end

      def finished?
        turns_left.zero? || players.count(&:alive) <= 1
      end

      def players
        board
          .flatten
          .select { |a| a.is_a?(Entities::Player) }
      end
    end
  end
end
