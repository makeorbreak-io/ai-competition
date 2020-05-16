module Games
  module Bomberman
    module Entities
      class Player < Struct.new(:id, :alive, :points, :simultaneous_bombs, :bomb_range)
        include Components::Positioned
      end
    end
  end
end
