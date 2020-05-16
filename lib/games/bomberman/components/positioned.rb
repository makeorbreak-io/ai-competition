module Games
  module Bomberman
    module Components
      module Positioned
        attr_accessor :position

        def positioned_at(position)
          dup.tap { |e| e.position = position }
        end
      end
    end
  end
end
