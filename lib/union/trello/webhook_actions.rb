module Union::Trello
  module WebhookActions

  end
end

require_relative 'webhook_actions/create_card'
require_relative 'webhook_actions/convert_to_card_from_check_item'
require_relative 'webhook_actions/add_member_to_card'
require_relative 'webhook_actions/add_label_to_card'
require_relative 'webhook_actions/remove_member_from_card'
require_relative 'webhook_actions/update_card'
require_relative 'webhook_actions/unknown_action'
require_relative 'webhook_actions/move_card_from_board'
require_relative 'webhook_actions/move_card_to_board'
require_relative 'webhook_actions/delete_card'
