module Games
  module Bomberman
    module Action
      DIRECTIONS = {
        down: [1, 0],
        left: [0, -1],
        right: [0, 1],
        up: [-1, 0],
      }.freeze

      class DropBomb < Struct.new(:player_id, :at)
        def to_json
          {
            "action" => "bomb",
            "at" => at,
            "player_id" => player_id,
          }
        end
      end

      class Move < Struct.new(:player_id, :from, :to)
        def to_json
          {
            "action" => "move",
            "from" => from,
            "player_id" => player_id,
            "to" => to,
          }
        end
      end

      def self.build(state, player_id, action)
        case action
        when "bomb"
          position = state.entities.find { |entity| entity.is_a?(Entities::Player) && entity.id == player_id }.position

          DropBomb.new(player_id, position)
        when "up", "down", "left", "right"
          position = state.entities.find { |entity| entity.is_a?(Entities::Player) && entity.id == player_id }.position
          direction = DIRECTIONS.fetch(action.to_sym)

          Move.new(
            player_id,
            position,
            [position[0] + direction[0], position[1] + direction[1]],
          )
        end
      end
    end
  end
end
