require 'spec_helper'

describe ApplicationHelper do
  describe '#email_name' do
    context 'when string is not an email address' do
      it 'the string as is' do
        expect(helper.email_name 'ci.yourcompany.com').to eq 'ci.yourcompany.com'
      end
    end

    context 'when string is an email address' do
      it 'returns capitalized name' do
        expect(helper.email_name 'someone@yourcompany.com').to eq 'Someone'
      end

      context 'when title contains multiple words' do
        it 'returns full capitalized name' do
          expect(helper.email_name 'cool-really_long.name@yourcompany.com').to eq 'Cool Really Long Name'
        end
      end
    end
  end
end
