module ExceptionNotifier
  class WebhookNotifier

    def initialize(options)
      @default_options = options
    end

    def call(exception, options={})
      env = options[:env]

      options = options.reverse_merge(@default_options)
      url = options.delete(:url)
      http_method = options.delete(:http_method) || :post

      request = ActionDispatch::Request.new(env)

      options[:body] ||= {}
      options[:body][:exception] = {:error_class => exception.class.to_s,
                                    :message => exception.message.inspect,
                                    :backtrace => exception.backtrace,
                                    :cookies => request.cookies.inspect,
                                    :url => request.original_url,
                                    :ip_address => request.ip,
                                    :environment => env.inspect,
                                    :controller => env['action_controller.instance'] || MissingController.new,
                                    :session => env['action_dispatch.request.unsigned_session_cookie'].inspect,
                                    :parameters => env['action_dispatch.request.parameters'].inspect
                                  }

      HTTParty.send(http_method, url, options)
    end
  end
end
