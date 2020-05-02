module Games
  module Bomberman
    module Entities
      class StrongerBombs < Struct.new(:position)
        include Positioned
      end
    end
  end
end
