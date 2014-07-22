module Union::Trello
  class API
    include HTTParty
    base_uri 'https://api.trello.com/1'

    def initialize(developer_public_key, member_token)
      @developer_public_key = developer_public_key
      @member_token = member_token
    end

    def credentials
      { key: @developer_public_key, token: @member_token }
    end

    def list_cards(list_id)
      options = { query: credentials.merge(members: 'true', actions: 'createCard,convertToCardFromCheckItem,copyCard') }
      self.class.get("/lists/#{list_id}/cards", options)
    end

    def archive(card_id)
      options = { query: credentials.merge(value: 'true') }
      self.class.put("/cards/#{card_id}/closed", options)
    end

    def card(card_id)
      self.class.get("/cards/#{card_id}", query: credentials)
    end

    def done_cards(board)
      options = { query: credentials.merge(actions: 'updateCard:idList') }
      self.class.get("/lists/#{board.done_list_id}/cards", options)
    end

    # Returns all boards accessible with available credentials.
    #
    # @return [Array<Hash>] boards
    def boards
      options = { query: credentials.merge(filter: 'open') }
      self.class.get('/members/me/boards', options)
    end

    # Registers trello webhook for board.
    #
    # @return [Hash] webhook creation response
    def webhook_subscribe(trello_board_id)
      options = { query: credentials.merge(idModel: trello_board_id, callbackURL: APP_CONFIG[:trello][:webhook_callback_url]) }
      self.class.put('/webhooks', options)
    end

    # Deletes an existing webhook.
    def webhook_unsubscribe(trello_webhook_id)
      self.class.delete("/webhooks/#{trello_webhook_id}", query: credentials)
    end

    def board_lists(trello_board_id)
      self.class.get("/boards/#{trello_board_id}/lists", query: credentials)
    end
  end
end
