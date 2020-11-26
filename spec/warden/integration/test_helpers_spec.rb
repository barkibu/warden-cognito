require 'spec_helper'
require 'rack'

RSpec.describe Warden::Cognito::TestHelpers do
  include_context 'fixtures'
  include_context 'configuration'

  describe '#auth_headers' do
    let(:headers) { { foo: 'bar' } }
    let(:user_repository) { double 'UserRepository' }
    let(:user) { double 'User' }
    let(:cognito_id) { 'User Cognito Identifying Attribute Value' }

    subject(:auth_headers) { Warden::Cognito::TestHelpers.auth_headers(headers, user) }

    before do
      Warden::Cognito.config.user_repository = user_repository
      Warden::Cognito::TestHelpers.setup
      allow(user).to receive(:cognito_id).and_return(cognito_id)
    end

    it 'overrides the headers with Bearer token in Authorization' do
      expect(auth_headers).to match hash_including headers.except(:Authorization)
      expect(auth_headers).to have_key :Authorization
    end

    it 'returns a valid token' do
      token_decoder = token_decoder(auth_headers)

      expect(token_decoder.validate!).to be_truthy
    end

    it 'returns a token identifying the provided user' do
      token_decoder = token_decoder(auth_headers)

      expect(user_repository).to receive(:find_by_cognito_attribute).with(cognito_id).and_return(user)
      expect(Warden::Cognito::LocalUserMapper.find(token_decoder)).to eq user
    end

    def token_decoder(headers)
      token = headers[:Authorization].split[1]
      Warden::Cognito::TokenDecoder.new(token)
    end
  end
end
