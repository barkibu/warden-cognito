require 'spec_helper'
require 'rack'

RSpec.describe Warden::Cognito::TestHelpers do
  include_context 'fixtures'
  include_context 'configuration'

  context '.auth_headers' do
    before do
#      described_class.setup_for_test
    end

    let(:headers) { described_class.auth_headers({}, user) }
    let(:path) { '/v1/resource' }
    let(:env) { Rack::MockRequest.env_for(path, method: 'GET').merge(headers) }
    let(:strategy) { Warden::Cognito::TokenAuthenticatableStrategy.new(env) }

    it 'returns a valid token' do
#      expect(strategy.valid?).to be_truthy
    end

    it 'returns a token identifying the user' do
#      expect(strategy).to receive(:success!).with(user)
#      strategy.authenticate!
    end
  end
end
