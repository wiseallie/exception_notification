module ExceptionNotifier
  class SlackNotifier

    attr_accessor :notifier

    def initialize(options)
      begin
        team = options.fetch(:team)
        token = options.fetch(:token)
        custom_hook = options.fetch(:custom_hook, nil)
        options[:username] ||= 'ExceptionNotifierBot'
        @message_opts = options.fetch(:additional_parameters, {})

        if custom_hook.nil?
          @notifier = Slack::Notifier.new team, token, options
        else
          @notifier = Slack::Notifier.new team, token, custom_hook, options
        end
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
