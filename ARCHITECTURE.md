## Problems identified during the first edition

We limited players' turn runtime in seconds. This created an advantage to some
fast languages.


## Engine parts

```ruby
module Game
  class State
    def self.parse(io); State.new end
    def to_s; ""; end
    def to_player; {}; end
    def finished?; true; end
    def player_ids; []; end
  end

  class Action
    def self.build(state:, player_id:, action:); Action.new; end
    def to_json; {}; end
  end

  class Stepper
    def self.next(state:, actions:); State.new; end
  end

  def self.limit; 100; end
end

## General

# Player:
# - new(player_id: Number, source_code: String, limit: Number)
# - next(local_state: JSON) -> Result<JSON, Error>


# Game::State.from_s(File.read("level1.txt"))
```
