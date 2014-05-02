require_relative 'base'

module Union::Trello::WebhookActions
  class AddLabelToCard < Base
    def process
      super

      card.label = data[:value]

      post_process
    end
  end
end
