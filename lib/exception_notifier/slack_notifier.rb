module ExceptionNotifier
  class SlackNotifier

    attr_accessor :notifier

    def initialize(options)
      begin
        webhook_url = options.fetch(:webhook_url)
        @message_opts = options.fetch(:additional_parameters, {})
        @notifier = Slack::Notifier.new webhook_url, options
      rescue
        @notifier = nil
      end
    end

    def call(exception, options={})
      message = "An exception occurred: '#{exception.message}' on '#{exception.backtrace.first}'"
      @notifier.ping(message, @message_opts) if valid?
    end

    protected

    def valid?
      !@notifier.nil?
    end
  end
end
