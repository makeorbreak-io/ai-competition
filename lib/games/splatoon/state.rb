module Games
  module Splatoon
    class State < Struct.new(
      :width,
      :height,
      :player_positions,
      :colors,
      :turns_left,
      :previous_actions,
      keyword_init: true
    )
      def self.parse(io)
        Reader.read(io)
      end

      def to_s
        Writer.write(self)
      end

      def to_player(id:)
        {}
      end

      def player_ids
        players.map(&:id)
      end

      def score
        colors.
          values.
          compact.
          group_by(&:itself).
          transform_values(&:length)
      end

      def finished?
        turns_left.zero? || players.count(&:alive) <= 1
      end
    end
  end
end
