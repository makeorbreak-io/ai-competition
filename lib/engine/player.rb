require 'rlua'

module Engine
  class Player
    class Error < StandardError
    end

    attr_accessor :id, :source_code, :game

    def initialize(id:, source_code:, game:)
      self.id = id
      self.source_code = source_code
      self.game = game
    end

    def next(local_state:)
      build_sandbox.next(local_state)
    end

    def build_sandbox
      Lua::State.new.tap do |sandbox|
        sandbox.__bootstrap
        sandbox.__load_stdlib(:string, :math, :debug, :base, :table)

        sandbox.limit = game.limit
        sandbox.__eval File.read("scripts/prelude.lua")
        sandbox.print = -> (*x) { puts x.inspect }

        begin
          sandbox.__eval(source_code)
        rescue => e
          raise Error, e.message
        rescue SyntaxError => e
          raise Error, e.message
        end
      end
    end
  end
end
