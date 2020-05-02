module Engine
  class Runner
    attr_accessor :game
    def initialize(game)
      self.game = game
    end

    def run(state, players)
      block_given? && yield(nil, state)

      while !state.finished?
        actions = players.map do |player|
          local_state = state.to_player(id: player.id)
          action = player.next(local_state: local_state)
          game::Action.build(state, player.id, action)
        end

        state = game::Stepper.next(state, actions)

        block_given? && yield(actions, state)
      end

      state
    end
  end
end
