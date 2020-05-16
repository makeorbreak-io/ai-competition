module Games
  module Bomberman
    module Entities
      class Coin < Struct.new(:points)
        include Components::Positioned
      end
    end
  end
end
