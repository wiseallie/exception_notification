require 'resque/failure/base'

# Usage:
#   require 'resque/failure/multiple'
#   require 'resque/failure/redis'
#   require 'exception_notification/resque'
#   Resque::Failure::Multiple.classes = [Resque::Failure::Redis, ExceptionNotification::Resque]
#   Resque::Failure.backend = Resque::Failure::Multiple

module ExceptionNotification
  class Resque < Resque::Failure::Base

    def self.count
      Stat[:failed]
    end

    def save
      data = {
        :failed_at     => Time.now.to_s,
        :queue         => queue,
        :worker        => worker.to_s,
        :payload       => payload,
        :error_class   => exception.class.name,
        :error_message => exception.message
      }

      ExceptionNotifier.notify_exception(exception, :data => { :resque => data })
    end

  end
end
