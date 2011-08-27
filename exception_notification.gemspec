Gem::Specification.new do |s|
  s.name = 'exception_notification'
  s.version = '2.5.0'
  s.authors = ["Jamis Buck", "Josh Peek"]
  s.date = %q{2011-08-27}
  s.summary = "Exception notification by email for Rails apps"
  s.email = "smartinez87@gmail.com"

  s.files = Dir['Rakefile', '.gemtest', 'README.md' 'lib/**/*']
  s.test_files = Dir.glob "test/**/*_test.rb"
  s.require_path = 'lib'

  s.add_dependency("actionmailer", ">= 3.0.4")
  s.add_development_dependency "rails", ">= 3.0.4"
  s.add_development_dependency "sqlite3", ">= 1.3.4"
end
