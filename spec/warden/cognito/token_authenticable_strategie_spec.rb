require 'spec_helper'
require 'rack'

RSpec.describe Warden::Cognito::TokenAuthenticatableStrategy do
  include_context 'fixtures'
  include_context 'configuration'

  let(:jwt_token) { 'FakeJwtToken' }
  let(:headers) { { 'HTTP_AUTHORIZATION' => "Bearer #{jwt_token}" } }
  let(:path) { '/v1/resource' }
  let(:env) { Rack::MockRequest.env_for(path, method: 'GET').merge(headers) }
  subject(:strategy) { described_class.new(env) }
  let(:kb_uuid) { user.id }
  let(:decoded_token) do
    [
      {
        'sub' => 'CognitoUserId'
      }
    ]
  end

  let(:client) { double 'Client' }

  before do
    allow(Aws::CognitoIdentityProvider::Client).to receive(:new).and_return client
    allow(JWT).to receive(:decode).and_return(decoded_token)
    allow(strategy).to receive(:jwks).and_return []
  end

  describe '.valid?' do
    it 'grab the token from the Authorization header' do
      expect(JWT).to receive(:decode).with(jwt_token, any_args)
      strategy.valid?
    end

    context 'with a token issued by another entity' do
      before { allow(JWT).to receive(:decode).and_raise(JWT::InvalidIssuerError) }

      it 'returns false' do
        expect(strategy.valid?).to be_falsey
      end
    end

    context 'with a token issued by Cognito' do
      it 'returns true' do
        expect(strategy.valid?).to be_truthy
      end

      context 'expired' do
        before { allow(JWT).to receive(:decode).and_raise(JWT::ExpiredSignature) }

        it 'returns true' do
          expect(strategy.valid?).to be_truthy
        end
      end
    end
  end

  describe '.authenticate' do
    it 'grab the token from the Authorization header' do
      expect(JWT).to receive(:decode).with(jwt_token, any_args)
      strategy.valid?
    end

    context 'with an expired token' do
      before { allow(JWT).to receive(:decode).and_raise(JWT::ExpiredSignature) }

      it 'fails and halts all authentication strategies' do
        expect(strategy).to receive(:fail!).with(:token_expired)
        strategy.authenticate!
      end
    end

    context 'with a valid token' do
      before { allow(client).to receive(:get_user).and_return cognito_user }

      context 'referencing an existing (local) user' do
        it 'succeeds with the user instance' do
          expect(config.user_repository).to receive(:find_by_cognito_attribute).with(local_identifier).and_call_original
          expect(strategy).to receive(:success!).with(user)
          strategy.authenticate!
        end
      end

      context 'referencing a new user' do
        before do
          config.user_repository = nil_user_repository
        end

        it 'calls the `after_local_user_not_found` callback' do
          expect(config.after_local_user_not_found).to receive(:call).with(cognito_user).and_call_original
          strategy.authenticate!
        end

        context 'with `after_local_user_not_found` returning nil' do
          before do
            config.after_local_user_not_found = Fixtures::Callback.after_user_local_not_found_nil
          end

          it 'fails! with :unknown_user' do
            expect(strategy).to receive(:fail!).with(:unknown_user)
            strategy.authenticate!
          end
        end

        context 'with `after_local_user_not_found` returning a user' do
          before do
            config.after_local_user_not_found = Fixtures::Callback.after_user_local_not_found_user
          end

          it 'success! with the given user' do
            expect(strategy).to receive(:success!).with(user)
            strategy.authenticate!
          end
        end
      end
    end
  end
end
