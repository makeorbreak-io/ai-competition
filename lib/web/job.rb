require "securerandom"

module Web
  class Job
    class <<self
      class NotFound < Exception; end

      def parse(str)
        type, payload, callback_url, auth_token = JSON.parse(str).values_at("type", "payload", "callback_url", "auth_token")

        {
          id: SecureRandom.uuid,
          type: type,
          payload: JSON.generate(payload),
          status: "new",
          callback_url: callback_url,
          auth_token: auth_token,
        }
      end

      include JobAWS

      # def poll { |job, control| }
      # def fetch(id)
      # def store(job)
      # def store_results(id, results)
      # def enqueue(job)
    end
  end
end
