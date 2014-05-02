require_relative 'base'

module Union::Trello::WebhookActions
  class ConvertToCardFromCheckItem < Base
    # Unlike createCard, convertToCardFromCheckItem action doesn't arrive with a list ID, so we're going to let the
    # post_process handle assignment of trello_list_id.
    def process
      super

      # Chill out.

      post_process
    end
  end
end
