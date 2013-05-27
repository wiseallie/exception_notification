require 'active_support/core_ext/string/inflections'

module ExceptionNotifier

  autoload :Notifier, 'exception_notifier/notifier'
  autoload :EmailNotifier, 'exception_notifier/email_notifier'
  autoload :CampfireNotifier, 'exception_notifier/campfire_notifier'
  autoload :WebhookNotifier, 'exception_notifier/webhook_notifier'

  class UndefinedNotifierError < StandardError; end

  # Define a set of exceptions to be ignored, ie, dont send notifications when any of them are raised.
  mattr_accessor :ignored_exceptions
  @@ignored_exceptions = %w{ActiveRecord::RecordNotFound AbstractController::ActionNotFound ActionController::RoutingError}

  class << self
    @@notifiers = {}

    def notify_exception(exception, options={})
      return if ignored_exception?(options[:ignore_exceptions], exception)
      selected_notifiers = options.delete(:notifiers) || notifiers
      [*selected_notifiers].each do |notifier|
        fire_notification(notifier, exception, options.dup)
      end
    end

    def register_exception_notifier(name, notifier_or_options)
      if notifier_or_options.respond_to?(:call)
        @@notifiers[name] = notifier_or_options
      elsif notifier_or_options.is_a?(Hash)
        create_and_register_notifier(name, notifier_or_options)
      else
        raise ArgumentError, "Invalid notifier '#{name}' defined as #{notifier_or_options.inspect}"
      end
    end

    def unregister_exception_notifier(name)
      @@notifiers.delete(name)
    end

    def registered_exception_notifier(name)
      @@notifiers[name]
    end

    def notifiers
      @@notifiers.keys
    end

    private
    def ignored_exception?(ignore_array, exception)
      (Array(ignored_exceptions) + Array(ignore_array)).map(&:to_s).include?(exception.class.name)
    end

    def fire_notification(notifier_name, exception, options)
      notifier = registered_exception_notifier(notifier_name)
      notifier.call(exception, options)
    rescue
      false
    end

    def create_and_register_notifier(name, options)
      notifier_classname = "#{name}_notifier".camelize
      notifier_class = ExceptionNotifier.const_get(notifier_classname)
      notifier = notifier_class.new(options)
      register_exception_notifier(name, notifier)
    rescue NameError => e
      raise UndefinedNotifierError, "No notifier named '#{name}' was found. Please, revise your configuration options. Cause: #{e.message}"
    end
  end
end
