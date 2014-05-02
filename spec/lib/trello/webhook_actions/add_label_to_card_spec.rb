require 'spec_helper'

module Union::Trello::WebhookActions
  describe AddLabelToCard do
    include WebhookRequestHelpers

    let(:add_label_to_card_request) { load_request(:add_label_to_card) }
    let(:add_label_to_card_object) { JSON.parse(add_label_to_card_request).with_indifferent_access }

    subject { described_class.new add_label_to_card_object }

    describe '#process' do
      let!(:card) { create :card, trello_id: '52cfad1fa961d42d16fa28c7' }

      it 'sets the value of label to the colour of added label' do
        subject.process
        card.reload
        expect(card.label).to eq 'red'
      end
    end
  end
end
