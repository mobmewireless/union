Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, APP_CONFIG['google_credentials']['client_id'], APP_CONFIG['google_credentials']['client_secret']
end