require_relative 'base'

module Union::Trello::WebhookActions
  class CreateCard < Base
    def process
      super

      card.trello_list_id = data[:list][:id]

      post_process
    end
  end
end
