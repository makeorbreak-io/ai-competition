require "json"

module Games
  module Bomberman
    class State < Struct.new(
      :width,
      :height,
      :turn,
      :turns_left,
      :entities,
      keyword_init: true
    )
      def self.parse(io)
        Reader.read(io)
      end

      def to_s
        Writer.write(self)
      end

      def to_player(id:)
        ToPlayer.to_player(state: self, id: id)
      end

      def player_ids
        players.map(&:id)
      end

      def finished?
        turns_left.zero? || players.count(&:alive) <= 1
      end

      private

      def players
        entities.select { |e| e.is_a?(Entities::Player) }
      end
    end
  end
end
