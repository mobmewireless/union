require 'spec_helper'

describe ApiController do
  include WebhookRequestHelpers

  describe "HEAD 'webhook'" do
    it 'responds to indicate presence of active route' do
      head 'webhook'
      expect(response.code).to eq '200'
      expect(response.body.strip).to be_empty
    end
  end

  # The webhook endpoint is secured with HMAC Hash authentication which ensures that only requests made by Trello are
  # processed. Note the header being set in the first before :each block.
  describe "POST 'webhook'" do
    let(:trello_action) { load_request :create_card }

    before :each do
      Union::Trello::WebhookProcessor.stub :process
      APP_CONFIG[:trello][:webhook_callback_url] = 'http://union-web.com/callback'
      APP_CONFIG[:trello][:api_secret] = 'SUPER_SECRET_STRING'
      request.headers['x-trello-webhook'] = Base64.strict_encode64(OpenSSL::HMAC.digest OpenSSL::Digest::SHA1.new, 'SUPER_SECRET_STRING', "#{trello_action}http://union-web.com/callback")
    end

    after :each do
      APP_CONFIG[:trello][:webhook_callback_url] = ENV['TRELLO_WEBHOOK_CALLBACK_URL']
      APP_CONFIG[:trello][:api_secret] = ENV['TRELLO_API_SECRET']
    end

    it 'invokes webhook data processor' do
      Union::Trello::WebhookProcessor.should_receive(:process).with(trello_action)
      post 'webhook', trello_action
    end

    it 'returns http success' do
      post 'webhook', trello_action
      expect(response).to be_success
    end

    context 'when the x-trello-webhook value does is not a valid HMAC Hash' do
      it 'responds with error code' do
        request.env['x-trello-webhook'] = 'INVALID_HMAC_HASH_VALUE'
        post 'webhook', 'foo'
        expect(JSON.parse(response.body)['code']).to eq 'WebhookAuthenticationFailed'
      end
    end

    context 'when the processor raises an error' do
      it 'responds with error code' do
        Union::Trello::WebhookProcessor.stub(:process).and_raise(Exceptions::WebhookInvalidJson)
        request.headers['x-trello-webhook'] = Base64.strict_encode64(OpenSSL::HMAC.digest OpenSSL::Digest::SHA1.new, 'SUPER_SECRET_STRING', 'foohttp://union-web.com/callback')
        post 'webhook', 'foo'
        expect(JSON.parse(response.body)['code']).to eq 'WebhookInvalidJson'
      end
    end
  end
end
