require_relative 'base'

module Union::Trello::WebhookActions
  class DeleteCard < Base
    def process
      super

      card.deleted = true

      post_process
    end
  end
end
