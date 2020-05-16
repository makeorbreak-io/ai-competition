module Games
  module Bomberman
    module Entities
      class Player < Struct.new(:id, :alive)
        include Components::Positioned
      end
    end
  end
end
