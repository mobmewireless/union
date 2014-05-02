require_relative 'base'

module Union::Trello::WebhookActions
  # @author Hari Gopal <mail@harigopal.in>
  class UpdateCard < Base
    # This method handles three forms of card update - moving card from one list to another, changing its archived
    # state, or altering its due date. There's some amount of bookkeeping to be performed during list move, so the
    # method is somewhat 'fat'.
    def process
      super

      # Update card data.
      card.data.deep_merge!(card: data[:card])

      if data[:old].include?(:idList)
        # Moving card from one list to another.
        card.trello_list_id = data[:listAfter][:id]

        case card.status
          when Card::STATUS_WIP
            # Update started_at if it isn't set already.
            if card.started_at.nil?
              card.started_at = Time.now
            end
          when Card::STATUS_DONE
            # Update completed_at if it isn't set already.
            if card.completed_at.nil?
              card.completed_at = Time.now
            end
        end
      elsif data[:old].include?(:closed)
        # Archiving or un-archiving a card.

        card.archived = !data[:old][:closed]
      elsif data[:old].include?(:due)
        # Adding or removing due date on card.

        card.due = data[:card][:due].nil? ? nil : Time.parse(data[:card][:due])
      elsif data[:old].include?(:desc)
        # Scan for and add tags from description.

        card.scan_and_add_tags data[:card][:desc]
      elsif data[:old].include?(:name)
        # Scan for and add tags from name.

        card.scan_and_add_tags data[:card][:name]
      end

      post_process
    end
  end
end
