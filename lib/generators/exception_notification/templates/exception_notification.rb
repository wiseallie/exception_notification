<% if options.sidekiq? %>
require 'exception_notification/sidekiq'
<% end %>
<% if options.resque? %>
require 'resque/failure/multiple'
require 'resque/failure/redis'
require 'exception_notification/resque'

Resque::Failure::Multiple.classes = [Resque::Failure::Redis, ExceptionNotification::Resque]
Resque::Failure.backend = Resque::Failure::Multiple
<% end %>
