require "aws-sdk-s3"
require "aws-sdk-sqs"

module Web
  module JobAWS
    def poll(&block)
      poller = Aws::SQS::QueuePoller.new(ENV.fetch("JOB_QUEUE_URL"))

      poller.poll do |message|
        block.call(fetch(message.body), JobControl.new(poller, message))
      end
    end

    def fetch(id)
      parse(bucket.object(id).get.body.read)
    end

    def store(job)
      bucket.object(job[:id]).put(acl: "private", body: job.to_json)
    end

    def store_results(id, results)
      job = fetch(id).merge(results: results)

      store(job)
    end

    def enqueue(job)
      store(job)
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
