module Games
  module Bomberman
    module Entities
      class Bomb < Struct.new(:timer, :radius, :player)
        include Components::Positioned
      end
    end
  end
end
