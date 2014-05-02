require 'spec_helper'

module Union::Trello::WebhookActions
  describe RemoveMemberFromCard do
    include WebhookRequestHelpers

    let(:remove_member_from_card_request) { load_request(:remove_member_from_card) }
    let(:remove_member_from_card_object) { JSON.parse(remove_member_from_card_request).with_indifferent_access }

    subject { described_class.new remove_member_from_card_object }

    describe '#process' do
      let(:card) { create :card, trello_id: '52a830a421b43ee42f0237a4' }

      before :each do
        card.data.merge!({ members: { '4f475005f7aabce304d48c5a' => { some: 'thing' }, '52a82b060ab45b5130021afd' => { something: 'else' } } })
        card.save
      end

      it 'removes member from the card' do
        subject.process
        card.reload
        expect(card.data[:members].count).to eq(1)
        expect(card.data[:members]['4f475005f7aabce304d48c5a']).to eq(nil)
      end
    end
  end
end
