require "active_support/core_ext/hash/keys"
require "json"
require "securerandom"

module Web
  class Job
    class <<self
      class NotFound < Exception; end

      def from_http(body)
        type, payload, callback_url, auth_token = JSON.parse(body).values_at("type", "payload", "callback_url", "auth_token")

        {
          id: SecureRandom.uuid,
          type: type,
          payload: JSON.generate(payload),
          callback_url: callback_url,
          auth_token: auth_token,
        }
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
