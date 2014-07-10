ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'fakeweb'
require 'fileutils'
require 'fakefs/safe'

FakeWeb.allow_net_connect = false

# Let's run delayed jobs immediately for specs.
Delayed::Worker.delay_jobs = false

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

APP_CONFIG[:allowed_email_host] = 'example.org'

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Factory Girl for models.
  config.include FactoryGirl::Syntax::Methods

  config.infer_spec_type_from_file_location!

  config.include Devise::TestHelpers, type: :controller
end

module WebhookRequestHelpers
  def load_request(type)
    File.read(File.join(Rails.root, 'spec', 'lib', 'trello', 'webhook_requests', "#{type}.json"))
  end
end

module AuthenticationHelpers

  def test_user
    @test_user ||= FactoryGirl.create(:user)
  end

  def login_as_user!(user = test_user)
    user.confirm!
    sign_in :user, user
  end

  def login_as_admin!
    user = test_user
    APP_CONFIG['admin_emails'] ||= []
    APP_CONFIG['admin_emails'] << user.email
    login_as_user!(user)
  end
end
