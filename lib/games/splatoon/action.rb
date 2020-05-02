module Games
  module Splatoon
    module Action
      DIRECTIONS = [
        [-1, -1], [-1, 0], [-1, 1],
        [ 0, -1],          [ 0, 1],
        [ 1, -1], [ 1, 0], [ 1, 1],
      ].freeze

      class Shoot < Struct.new(:player_id, :direction)
        def to_json
          {
            "action" => "shoot",
            "direction" => direction,
            "player_id" => player_id,
          }
        end
      end

      class Walk < Struct.new(:player_id, :from, :to)
        def to_json
          {
            "action" => "walk",
            "from" => from,
            "player_id" => player_id,
            "to" => to,
          }
        end
      end

      def self.build(state, player_id, action)
        position = state
          .players
          .find { |player| player.id == player_id }
          .position

        case action["type"]
        when "walk"
          direction = actions.fetch("direction")
          raise unless DIRECTIONS.include?(direction)

          Walk.new(
            player_id,
            position,
            [position[0] + direction[0], position[1] + direction[1]],
          )
        when "shoot"
          direction = actions.fetch("direction")
          raise unless DIRECTIONS.include?(direction)

          Shoot.new(player_id, direction)
        end
      end
    end
  end
end
