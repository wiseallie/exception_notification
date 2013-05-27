require 'active_support/deprecation'

module ExceptionNotification
  class Rack
    def initialize(app, options = {})
      @app = app

      @options = {}
      @options[:ignore_crawlers]    = options.delete(:ignore_crawlers) || []
      @options[:ignore_if]          = options.delete(:ignore_if) || ->(env, e) { false }
      ExceptionNotifier.ignored_exceptions = options.delete(:ignore_exceptions) if options.key?(:ignore_exceptions)

      options = make_options_backward_compatible(options)
      options.each do |notifier_name, options|
        ExceptionNotifier.register_exception_notifier(notifier_name, options)
      end
    end

    def call(env)
      @app.call(env)
    rescue Exception => exception
      options = @options.dup

      unless from_crawler(options[:ignore_crawlers], env['HTTP_USER_AGENT']) ||
            conditionally_ignored(options[:ignore_if], env, exception)
        ExceptionNotifier.notify_exception(exception, options.reverse_merge(:env => env))
        env['exception_notifier.delivered'] = true
      end

      raise exception
    end

    private

    def from_crawler(ignore_array, agent)
      ignore_array.each do |crawler|
        return true if (agent =~ Regexp.new(crawler))
      end unless ignore_array.blank?
      false
    end

    def conditionally_ignored(ignore_proc, env, exception)
      ignore_proc.call(env, exception)
    rescue Exception
      false
    end

    def make_options_backward_compatible(options)
      email_options_names = [:sender_address, :exception_recipients,
          :email_prefix, :email_format, :sections, :background_sections,
          :verbose_subject, :normalize_subject, :smtp_settings, :email_headers, :mailer_parent]

      if email_options_names.any?{|eo| options.has_key?(eo) }
        ActiveSupport::Deprecation.warn "You are using an old configuration style for ExceptionNotifier middleware. Please, revise your configuration options later."
        email_options = options.select{ |k,v| email_options_names.include?(k) }
        options.reject!{ |k,v| email_options_names.include?(k) }
        options[:email] = email_options
      end

      options
    end
  end
end
