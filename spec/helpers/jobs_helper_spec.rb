require 'spec_helper'

describe JobsHelper do
  describe '#labelize' do
    let(:log_1) { ['2014-04-03 09:22:26 [DEBUG] (9983) test string'] }
    let(:log_2) { ['(See full trace by running task with --trace)'] }
    let(:formatted_log_1) { ["<span style='color: grey;'>2014-04-03 14:52:26</span> <span class='label label-info job-log-label'>DEBUG</span> (9983) test string"] }
    let(:formatted_log_2) { ['(See full trace by running task with --trace)'] }

    context 'input with date and log level' do
      it 'returns html formatted output' do
        expect(helper.labelize(log_1)).to eq(formatted_log_1)
      end
    end

    context 'input without date and log level' do
      it 'returns text as it is' do
        expect(helper.labelize(log_2)).to eq(formatted_log_2)
      end
    end
  end
end
