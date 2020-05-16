module Games
  module Bomberman
    module Entities
      class Rock < Struct.new(:reward)
        include Components::Positioned
      end
    end
  end
end
