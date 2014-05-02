require_relative 'base'

module Union::Trello::WebhookActions
  class UnknownAction < Base
    def process
      # Do nothing for unknown cards, just log the event.
      logger.warn "Unknown card type #{type} encountered."
    end
  end
end
