module Games
  module Bomberman
    module Entities
      class Player < Struct.new(:id, :alive, :position)
        include Positioned
      end
    end
  end
end
