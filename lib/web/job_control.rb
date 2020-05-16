module Web
  class JobControl
    def initialize(poller, message)
      @poller = poller
      @message = message
    end

    def ping
      @poller.change_message_visibility_timeout(@message, 60)
    end

    def finish
      @poller.delete_message(@message)
    end
  end
end
