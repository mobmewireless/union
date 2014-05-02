require 'spec_helper'

module Union::Trello::WebhookActions
  describe DeleteCard do
    include WebhookRequestHelpers

    let(:delete_card_request) { load_request(:delete_card) }
    let(:delete_card_object) { JSON.parse(delete_card_request).with_indifferent_access }

    subject { described_class.new delete_card_object }

    describe '#process' do
      let!(:card) { create :card, trello_id: '531178697dad66e73ac6a03e' }

      it 'updates the board ID of card' do
        subject.process
        card.reload
        expect(card.deleted?).to eq(true)
      end
    end
  end
end
