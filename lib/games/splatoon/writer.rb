module Games
  module Splatoon
    module Writer
      def self.write(state)
        JSON.generate({
          colors: state.colors,
          height: state.height,
          player_positions: state.player_positions,
          previous_actions: state.previous_actions,
          turns_left: state.turns_left,
          width: state.width,
        })
      end
    end
  end
end
