require "httparty"

module Web
  class Worker
    attr_reader :game

    def initialize(game)
      @game = game
    end

    def notify_webhook(job)
      return if job[:callback].nil?

      HTTParty.post(
        job[:callback][:url],
        body: job.to_json,
        headers: {
          "Content-Type": "aplication/json",
          "Authorization": "Bearer #{job[:callback][:authorization]}",
        }
      )
    end

    def run!
      Job.poll do |job, control|
        players = job[:payload][:players].each_with_index.map do |source, idx|
          Engine::Player.new(
            id: idx,
            source_code: source,
            game: game,
          )
        end

        state = game::State.parse(StringIO.new(job[:payload][:state]))

        log = []

        Engine::Runner.new(game).run(state, players) do |actions, state|
          control.ping
          log << [actions, state]
        end

        Job.store_results(job[:id], log)
        notify_webhook(job)

        control.finish
      end
    end
  end
end
