require 'spec_helper'

module Union::Trello::WebhookActions
  describe ConvertToCardFromCheckItem do
    include WebhookRequestHelpers

    let(:convert_check_item_request) { load_request(:convert_to_card_from_check_it) }
    let(:convert_check_item_object) { JSON.parse(convert_check_item_request).with_indifferent_access }

    subject { described_class.new convert_check_item_object }

    describe '#process' do
      let!(:card) { create :card, trello_id: '52dcbff762c7f0b157e739c5' }

      it "doesn't do anything at the moment. See method documentation." do
        true
      end
    end
  end
end
