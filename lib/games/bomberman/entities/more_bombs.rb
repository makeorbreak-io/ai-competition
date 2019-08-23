module Games
  module Bomberman
    module Entities
      class MoreBombs < Struct.new(:position)
        include Positioned
      end
    end
  end
end
