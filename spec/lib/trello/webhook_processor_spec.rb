require 'spec_helper'

module Union::Trello
  describe WebhookProcessor do
    include WebhookRequestHelpers

    describe '.process' do
      shared_examples 'a specific processor' do |processor_class, incoming_request_type|
        let(:incoming_request) { load_request(incoming_request_type) }
        let(:incoming_request_object) { JSON.parse(incoming_request).with_indifferent_access }
        let(:mock_processor_class_instance) { double processor_class, process: nil }

        before do
          processor_class.stub new: mock_processor_class_instance
        end

        it 'instantiates processor class with parsed object' do
          processor_class.should_receive(:new).with(incoming_request_object)
          described_class.process incoming_request
        end

        it 'class process on instance of processor class' do
          mock_processor_class_instance.should_receive :process
          described_class.process incoming_request
        end
      end

      context 'when passed invalid JSON' do
        it 'raises Exceptions::WebhookInvalidJson' do
          expect {
            described_class.process('foo')
          }.to raise_error(Exceptions::WebhookInvalidJson)
        end
      end

      context 'when passed action which indicates creation of a card' do
        it_behaves_like 'a specific processor', WebhookActions::CreateCard, :create_card
      end

      context 'when passed action which indicates conversion of checklist item to card' do
        it_behaves_like 'a specific processor', WebhookActions::ConvertToCardFromCheckItem, :convert_to_card_from_check_item
      end

      context 'when passed action which indicates addition of member to a card' do
        it_behaves_like 'a specific processor', WebhookActions::AddMemberToCard, :add_member_to_card
      end

      context 'when passed action which indicates removal of member from a card' do
        it_behaves_like 'a specific processor', WebhookActions::RemoveMemberFromCard, :remove_member_from_card
      end

      context 'when passed action which indicates update of a card' do
        it_behaves_like 'a specific processor', WebhookActions::UpdateCard, :update_card_move_list
      end

      context 'when passed action which indicates addition of label to card' do
        it_behaves_like 'a specific processor', WebhookActions::AddLabelToCard, :add_label_to_card
      end

      context 'when passed action which indicates move of card from board' do
        it_behaves_like 'a specific processor', WebhookActions::MoveCardFromBoard, :move_card_from_board
      end

      context 'when passed action which indicates move of card to board' do
        it_behaves_like 'a specific processor', WebhookActions::MoveCardToBoard, :move_card_to_board
      end

      context 'when passed action which indicates deletion of card' do
        it_behaves_like 'a specific processor', WebhookActions::DeleteCard, :delete_card
      end
    end
  end
end
