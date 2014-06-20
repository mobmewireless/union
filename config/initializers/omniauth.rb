Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, APP_CONFIG['google_credentials']['client_id'], APP_CONFIG['google_credentials']['client_secret']
  provider :identity, on_failed_registration: lambda { |env| IdentitiesController.action(:new).call(env) }
end