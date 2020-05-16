module Web
  # This does not support multiple workers, and timing out and all of that is
  # not super tested. This is just so that people can get something running
  # locally without having to create AWS resources.
  module JobFile
    ROOT = ENV.fetch("JOB_FILE_PATH", "tmp")
    INBOX = File.join(ROOT, "inbox")
    JOBS = File.join(ROOT, "jobs")

    def fetch(id)
      parse(File.read(File.join(JOBS, id)))
    rescue
      raise Job::NotFound, "could not find job #{id}"
    end

    def store(job)
      FileUtils.mkdir_p(JOBS)
      File.write(
        File.join(JOBS, job[:id]),
        job.to_json,
      )
    end

    def enqueue(job)
      store(job)

      FileUtils.mkdir_p(INBOX)
      File.symlink(
        File.join(JOBS, job[:id]),
        File.join(INBOX, job[:id]),
      )
    end

    def poll(&block)
      FileUtils.mkdir_p(INBOX)

      loop do
        id = Dir[File.join(INBOX, "*")].first&.then { |fname| File.basename(fname) }

        if id
          block.call(fetch(id), JobControl.new(JobFile, id))
        end

        sleep 1
      end
    end

    class <<self
      def change_message_visibility_timeout(message, _timeout)
        # lol nope
      end

      def delete_message(id)
        File.unlink(File.join(INBOX, id))
      end
    end
  end
end
