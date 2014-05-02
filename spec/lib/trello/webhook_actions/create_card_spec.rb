require 'spec_helper'

module Union::Trello::WebhookActions
  describe CreateCard do
    include WebhookRequestHelpers

    let(:create_card_request) { load_request(:create_card) }
    let(:create_card_object) { JSON.parse(create_card_request).with_indifferent_access }

    subject { described_class.new create_card_object }

    describe '#process' do
      it 'stores trello list ID' do
        subject.process
        expect(Card.first.trello_list_id).to eq '52a82b69836ea6ce2f04c391'
      end
    end
  end
end
