module Web
  # This does not support multiple workers, and timing out and all of that is
  # not super tested. This is just so that people can get something running
  # locally without having to create AWS resources.
  module JobFile
    ROOT = ENV.fetch("JOB_FILE_PATH")
    INBOX = File.join(ROOT, "inbox")
    JOBS = File.join(ROOT, "jobs")
    TMP = File.join(ROOT, "tmp")

    def fetch(id)
      puts "fetching #{id}"

      parse(File.read(File.join(JOBS, id)))
    end

    def store(job)
      puts "storing #{job[:id]}"

      File.write(
        File.join(JOBS, job[:id]),
        job.to_json,
      )
    end

    def enqueue(job)
      puts "enqueueing #{job[:id]}"

      store(job)
      File.symlink(
        File.join(JOBS, job[:id]),
        File.join(INBOX, job[:id]),
      )
    end

    def poll(&block)
      loop do
        puts "looking for files in #{File.join(INBOX, "*")}"
        id = Dir[File.join(INBOX, "*")].first&.then { |fname| File.basename(fname) }

        if id
          puts "processing #{id}"
          block.call(fetch(id), JobControl.new(JobFile, id))
        end

        sleep 1
      end
    end

    class <<self
      def change_message_visibility_timeout(message, _timeout)
        puts "delaying #{id}"
        # lol nope
      end

      def delete_message(id)
        puts "marking #{id} as done"
        File.unlink(File.join(INBOX, id))
      end
    end
  end
end
