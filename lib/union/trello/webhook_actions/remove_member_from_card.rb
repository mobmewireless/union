require_relative 'base'

module Union::Trello::WebhookActions
  class RemoveMemberFromCard < Base
    def process
      super

      card.data[:members].delete(member[:id])

      post_process
    end

    private

    def member
      @action[:member]
    end
  end
end
