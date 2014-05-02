require_relative 'webhook_actions'

module Union::Trello
  # Dispatches the incoming JSON webhook action to corresponding processor.
  #
  # @author Hari Gopal <mail@harigopal.in>
  class WebhookProcessor
    class << self
      def process(webhook_json)
        begin
          webhook = JSON.parse(webhook_json).with_indifferent_access

          case webhook[:action][:type]
            when 'createCard'
              WebhookActions::CreateCard.new webhook
            when 'convertToCardFromCheckItem'
              WebhookActions::ConvertToCardFromCheckItem.new webhook
            when 'addMemberToCard'
              WebhookActions::AddMemberToCard.new webhook
            when 'addLabelToCard'
              WebhookActions::AddLabelToCard.new webhook
            when 'removeMemberFromCard'
              WebhookActions::RemoveMemberFromCard.new webhook
            when 'updateCard'
              WebhookActions::UpdateCard.new webhook
            when 'moveCardFromBoard'
              WebhookActions::MoveCardFromBoard.new webhook
            when 'moveCardToBoard'
              WebhookActions::MoveCardToBoard.new webhook
            when 'deleteCard'
              WebhookActions::DeleteCard.new webhook
            else
              WebhookActions::UnknownAction.new webhook
          end.process
        rescue JSON::ParserError
          raise Exceptions::WebhookInvalidJson
        end
      end
    end
  end
end
