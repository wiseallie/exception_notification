module ExceptionNotification
  class Engine < ::Rails::Engine
    config.exception_notification = ExceptionNotifier

    config.app_middleware.use ExceptionNotification::Rack
  end
end
