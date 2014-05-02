module Exceptions
  # Parent error class.
  class UnionError < StandardError
    def code
      self.class.name.demodulize
    end
  end

  # Errors raised when processing Trello webhook requests.
  class TrelloWebhookError < UnionError; end

  # Errors raised when processing server logs.
  class ServerLoggerExecutableMissing < UnionError; end

  # Raised errors follow.
  class DeployerError < UnionError; end
  class RefreshError < UnionError; end
  class ApiKeyInvalid < UnionError; end
  class ApiParametersMissing < UnionError; end
  class ApiParameterInvalid < UnionError; end
  class WebhookInvalidJson < TrelloWebhookError; end
  class WebhookAuthenticationFailed < TrelloWebhookError; end
end
