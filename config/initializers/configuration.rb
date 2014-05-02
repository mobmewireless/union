APP_CONFIG = {
  trello: {
    api_secret: ENV['TRELLO_API_SECRET'],
    webhook_callback_url: ENV['TRELLO_WEBHOOK_CALLBACK_URL']
  },
  google_credentials: {
    client_id: ENV['GOOGLE_CLIENT_ID'],
    client_secret: ENV['GOOGLE_CLIENT_SECRET']
  },
  access_tokens: ENV['UNION_API_ACCESS_TOKENS'] ? Hash[ENV['UNION_API_ACCESS_TOKENS'].split(';').map { |x| x.split(',') }]: nil,
  allowed_email_host: ENV['UNION_ALLOWED_EMAIL_HOST'],
  session_store_key: ENV['UNION_SESSION_STORE_KEY'] || '_union_session',
  admin_emails: ENV['UNION_ADMIN_EMAILS'].to_s.gsub(/\s+/, '').split(','),
  ossec_collector_path: ENV['OSSEC_COLLECTOR_PATH']
}.with_indifferent_access

