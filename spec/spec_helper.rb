require 'rspec/core'

if defined?(SimpleCov)
  SimpleCov.start do
    add_group 'Main', '/lib/'
  end
end

require 'appsent'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join('support','**','*.rb'),__FILE__)].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
end
