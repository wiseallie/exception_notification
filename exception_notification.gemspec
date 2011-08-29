Gem::Specification.new do |s|
  s.name = 'exception_notification'
  s.version = '2.5.1'
  s.authors = ["Jamis Buck", "Josh Peek"]
  s.date = %q{2011-08-29}
  s.summary = "Exception notification by email for Rails apps"
  s.email = "smartinez87@gmail.com"

  s.files = `git ls-files -- lib`.split("\n") + %w(Rakefile .gemtest README.md)
  s.test_files = Dir.glob "test/**/*_test.rb"
  s.require_path = 'lib'

  s.add_dependency("actionmailer", ">= 3.0.4")
  s.add_development_dependency "rails", ">= 3.0.4"
  s.add_development_dependency "sqlite3", ">= 1.3.4"
end
