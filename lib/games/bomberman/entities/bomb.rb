module Games
  module Bomberman
    module Entities
      class Bomb < Struct.new(:timer, :range, :player)
        include Components::Positioned
      end
    end
  end
end
