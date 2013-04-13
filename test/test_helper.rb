# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require "coveralls"
Coveralls.wear!

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rails/test_help"
require File.expand_path("../dummy/test/test_helper.rb", __FILE__)

require "test/unit"
require "mocha/setup"

Rails.backtrace_cleaner.remove_silencers!
