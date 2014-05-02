require_relative 'base'

module Union::Trello::WebhookActions
  class AddMemberToCard < Base
    def process
      super

      card.data[:members] ||= {}
      card.data[:members][member[:id]] = member.except(:id)

      post_process
    end

    private

    def member
      @action[:member]
    end
  end
end
