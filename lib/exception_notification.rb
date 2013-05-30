require 'exception_notifier'
require 'exception_notification/rack'
require 'exception_notification/rails' if defined?(Rails)

module ExceptionNotification
  # Alternative way to setup ExceptionNotification.
  # Run 'rails generate exception_notification:install' to create
  # a fresh initializer with all configuration values.
  def self.configure
    yield ExceptionNotifier
  end
end
