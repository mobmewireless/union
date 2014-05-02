require 'spec_helper'

describe MetricsHelper do

  describe '#humanize' do
    shared_examples 'humanize time' do |second, humanized_output|
      it "returns #{humanized_output} for #{second}" do
        expect(helper.humanize(second)).to eq(humanized_output)
      end
    end

    it_should_behave_like 'humanize time', 0, nil
    it_should_behave_like 'humanize time', 1, '< 1m'
    it_should_behave_like 'humanize time', 30, '< 1m'
    it_should_behave_like 'humanize time', 61, '1m'
    it_should_behave_like 'humanize time', 602, '10m'
    it_should_behave_like 'humanize time', 86461, '1d1m'
    it_should_behave_like 'humanize time', 3600, '1h'
  end

  describe '#card_date' do
    it 'returns "" for nil' do
      expect(helper.card_date(nil)).to eq('')
    end

    let(:time) { '2014-04-14 13:55:50 +0530'.to_time }
    let(:formatted_time) { 'Apr 14, 1:55 PM'}

    it 'returns formatted Indian standard time' do
      expect(helper.card_date(time)).to eq(formatted_time)
    end
  end
end
