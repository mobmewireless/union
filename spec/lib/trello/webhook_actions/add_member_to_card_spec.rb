require 'spec_helper'

module Union::Trello::WebhookActions
  describe AddMemberToCard do
    include WebhookRequestHelpers

    let(:add_member_to_card_request) { load_request(:add_member_to_card) }
    let(:add_member_to_card_object) { JSON.parse(add_member_to_card_request).with_indifferent_access }

    subject { described_class.new add_member_to_card_object }

    describe '#process' do
      let!(:card) { create :card, trello_id: '52b181af1d1afd88520108bd' }

      it 'adds member to data' do
        subject.process
        card.reload
        expect(card.data[:members]['52a82b060ab45b5130021afd']).to eq({ avatarHash: '439e7a9de37777e92eb51e3287a2aa4e', fullName: 'Super Coder', initials: 'SC', username: 'supercoder1' }.with_indifferent_access)
      end
    end
  end
end
