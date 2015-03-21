module ExceptionNotifier
  class SlackNotifier
    include BacktraceCleaner

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
      message = enrich_message_with_backtrace(message, exception)

      @notifier.ping(message, @message_opts) if valid?
    end

    protected

    def valid?
      !@notifier.nil?
    end

    def enrich_message_with_data(message, options)
      data = ((options[:env] || {})['exception_notifier.exception_data'] || {}).merge(options[:data] || {})
      data.reject!{|k,_| k == 'error_backtrace'}
      text = data.map{|k,v| "#{k}: #{v}"}.join(', ')

      if text.present?
        text = ['*Data:*', text].join("\n")
        [message, text].join("\n")
      else
        message
      end
    end

    def enrich_message_with_backtrace(message, exception)
      backtrace = clean_backtrace(exception).first(10).join("\n")
      [message, ['*Backtrace:*', backtrace]].join("\n")
    end

  end
end
