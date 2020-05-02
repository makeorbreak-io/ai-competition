module Games
  module Bomberman
    module Entities
      class Wall < Struct.new(:position)
        include Positioned
      end
    end
  end
end
