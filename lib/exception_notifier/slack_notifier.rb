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
      message = enrich_message_with_data(message, options)

      @notifier.ping(message, @message_opts) if valid?
    end

    protected

    def valid?
      !@notifier.nil?
    end

    def enrich_message_with_data(message, options)
      data = ((options[:env] || {})['exception_notifier.exception_data'] || {}).merge(options[:data] || {})
      text = data.map{|k,v| "#{k}: #{v}"}.join(', ')

      if text.present?
        message + " - #{text}"
      else
        message
      end
    end

  end
end
