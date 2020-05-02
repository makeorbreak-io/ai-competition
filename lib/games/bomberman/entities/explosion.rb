module Games
  module Bomberman
    module Entities
      class Explosion < Struct.new(:position)
        include Positioned
      end
    end
  end
end
