module Games
  module Bomberman
    module Entities
      class Rock < Struct.new(:reward, :position)
        include Positioned
      end
    end
  end
end
