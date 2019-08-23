require "securerandom"
require "aws-sdk-s3"
require "aws-sdk-sqs"

class Job
  class Control
    def initialize(poller, message)
      @poller = poller
      @message = message
    end

    def ping
    end

    def finish
      @poller.delete_message(@message)
    end
  end

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

    def poll(&block)
      poller = Aws::SQS::QueuePoller.new(ENV.fetch("JOB_QUEUE_URL"))

      poller.poll do |message|
        block.call(fetch(message.body), Control.new(poller, message))
      end
    end

    def fetch(id)
      parse(bucket.object(id).get.body.read)
    end

    def enqueue(job)
      bucket.object(job[:id]).put(acl: "private", body: job.to_json)
      queue.send_message(message_body: job[:id])
    end

    private
    def bucket
      client = Aws::S3::Client.new(region: ENV.fetch("JOB_STORAGE_REGION"))
      resource = Aws::S3::Resource.new(client: client)
      @bucket = resource.bucket(ENV.fetch("JOB_STORAGE_BUCKET_NAME"))
    end

    def queue
      client = Aws::S3::Client.new(region: ENV.fetch("JOB_STORAGE_REGION"))
      @queue = Aws::SQS::Queue.new(ENV.fetch("JOB_QUEUE_URL"), client)
    end
  end
end
