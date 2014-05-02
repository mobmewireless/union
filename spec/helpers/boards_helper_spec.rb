require 'spec_helper'

describe BoardsHelper do
  describe '#list_id_not_set' do
    it 'returns not set' do
      expect(helper.list_id_not_set).to eq('<em>Not Set</em>')
    end
  end
end
