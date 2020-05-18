require "active_support/core_ext/hash/keys"
require "json"
require "securerandom"

module Web
  Body = Web::Schema.build(
    type: "bomberman.match",
    payload: {
      players: [String],
      state: ->(path, state) do
        Games::Bomberman::State.parse(StringIO.new(state))
        []
      rescue
        Web::Schema.error(path, "valid game state", "something else")
      end,
    },
    callback: Schema.either(nil, { url: String, authorization: String }),
  )

  class Job
    class NotFound < Exception; end

    class <<self
      def from_http(body)
        params = Body[JSON.parse(body).deep_symbolize_keys]

        params.merge(id: SecureRandom.uuid)
      end

      def parse(str)
        JSON.parse(str).deep_symbolize_keys
      end

      def store_results(id, results)
        job = fetch(id).merge(results: results)

        store(job)
      end

      PROCESSORS = {
        "aws" => JobAWS,
        "file" => JobFile,
      }

      include PROCESSORS.fetch(ENV.fetch("JOB_PROCESSOR"))
    end
  end
end
