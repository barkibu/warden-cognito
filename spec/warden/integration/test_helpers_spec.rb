require 'spec_helper'
require 'rack'

RSpec.describe Warden::Cognito::TestHelpers do
  include_context 'fixtures'
  include_context 'configuration'

  describe '#auth_headers' do
    let(:headers) { { foo: 'bar' } }
    let(:user_repository) { double 'UserRepository' }
    let(:cognito_id) { 'User Cognito Identifying Attribute Value' }
    let(:user) { double 'User', cognito_id: cognito_id }
    let(:user_pool_configurations) do
      {
        "#{pool_identifier}": { region: region, pool_id: pool_id, client_id: client_id },
        particular_pool_identifier: { region: region, pool_id: pool_id, client_id: client_id }
      }
    end

    subject(:auth_headers) { Warden::Cognito::TestHelpers.auth_headers(headers, user, :particular_pool_identifier) }

    before do
      Warden::Cognito.config.user_repository = user_repository
      Warden::Cognito::TestHelpers.setup
    end

    it 'overrides the headers with Bearer token in Authorization' do
      expect(auth_headers).to match hash_including headers.except(:Authorization)
      expect(auth_headers).to have_key :Authorization
    end

    it 'returns a valid token' do
      token_decoder = token_decoder(auth_headers)

      expect(token_decoder.validate!).to be_truthy
    end

    it 'returns a token identifying the provided user with the specified pool identifier' do
      token_decoder = token_decoder(auth_headers)

      expect(user_repository).to receive(:find_by_cognito_attribute).with(cognito_id,
                                                                          :particular_pool_identifier).and_return(user)
      expect(Warden::Cognito::LocalUserMapper.find(token_decoder)).to eq user
    end

    def token_decoder(headers)
      token = headers[:Authorization].split[1]
      Warden::Cognito::TokenDecoder.new(token)
    end
  end
end
