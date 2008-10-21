# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/rails'

gem 'mocha', '>=0.5.2'

require 'user'
class User
  def self.create_test_user(email = "jack@black.com")
    User.create!(:email => email, :password => "pass", :password_confirmation => "pass")
  end

  def self.create_test_admin(email = "admin@black.com")
    User.create!(:email => email, :password => "pass", :password_confirmation => "pass", :admin => true)
  end
end

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures'
  
  config.mock_with :mocha
  config.include AuthenticatedTestHelper
end
