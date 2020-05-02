module Games
  module Bomberman
    module Entities
      class Bomb < Struct.new(:timer, :radius, :player, :position)
        include Positioned
      end
    end
  end
end
