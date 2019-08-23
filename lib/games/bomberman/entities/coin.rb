module Games
  module Bomberman
    module Entities
      class Coin < Struct.new(:points, :position)
        include Positioned
      end
    end
  end
end
