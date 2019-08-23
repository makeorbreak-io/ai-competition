module Games
  module Bomberman
    module Entities
      module Positioned
        def positioned_at(position)
          self.class.new(*values[0..-2], position)
        end
      end
    end
  end
end
