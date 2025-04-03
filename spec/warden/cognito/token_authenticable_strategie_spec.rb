require 'spec_helper'
require 'rack'

RSpec.describe Warden::Cognito::TokenAuthenticatableStrategy do
  include_context 'fixtures'
  include_context 'configuration'

  let(:jwt_token) { 'FakeJwtToken' }
  let(:headers) { {} }
  let(:cookies) { "AccessToken=#{jwt_token}" }
  let(:path) { '/v1/resource' }
  let(:env) { Rack::MockRequest.env_for(path, method: 'GET').merge(headers) }
  let(:issuer) { "https://cognito-idp.#{region}.amazonaws.com/#{pool_id}" }
  let(:decoded_token) do
    [
      {
        'sub' => 'CognitoUserId',
        'iss' => issuer
      }
    ]
  end

  let(:client) { double 'Client' }

  subject(:strategy) do
    env['HTTP_COOKIE'] = cookies
    described_class.new(env)
  end

  before do
    allow(Aws::CognitoIdentityProvider::Client).to receive(:new).and_return client
    allow(JWT).to receive(:decode).with(jwt_token, any_args).and_return(decoded_token)
    allow(strategy).to receive(:jwks).and_return []
  end

  describe '.valid?' do
    it 'grab the token from the cookie' do
      expect(JWT).to receive(:decode).with(jwt_token, nil, true, any_args)
      strategy.valid?
    end

    context "if an auth header isn't found" do
      let(:headers) { { 'HTTP_AUTHORIZATION' => "Bearer #{jwt_token}" } }
      it 'tries the auth header' do
        expect(JWT).to receive(:decode).with(jwt_token, nil, true, any_args)
        strategy.valid?
      end
    end

    context 'if both a cookie and auth header are supplied' do
      let(:headers) { { 'HTTP_AUTHORIZATION' => 'Bearer NotRealToken' } }

      it 'the cookie wins' do
        expect(JWT).to receive(:decode).with(jwt_token, nil, true, any_args)
        strategy.valid?
      end
    end

    context 'with a token issued by another entity' do
      before { allow(JWT).to receive(:decode).with(jwt_token, nil, true, any_args).and_raise(JWT::InvalidIssuerError) }

      it 'returns false' do
        expect(strategy.valid?).to be_falsey
      end
    end

    context 'with a token issued by Cognito' do
      it 'returns true' do
        expect(strategy.valid?).to be_truthy
      end

      context 'on an error' do
        before { allow(JWT).to receive(:decode).with(jwt_token, nil, true, any_args).and_raise(StandardError) }

        it 'returns false' do
          expect(strategy.valid?).to be_falsey
        end
      end
    end
  end

  describe '.authenticate' do
    it 'grab the token from the Authorization header' do
      expect(JWT).to receive(:decode).with(jwt_token, nil, true, any_args)
      strategy.valid?
    end

    context 'with a valid token' do
      before { allow(client).to receive(:get_user).and_return cognito_user }

      context 'referencing an existing (local) user' do
        it 'succeeds with the user instance' do
          expect(config.user_repository).to receive(:find_by_cognito_attribute).with(local_identifier,
                                                                                     pool_identifier).and_call_original
          expect(strategy).to receive(:success!).with(user)
          strategy.authenticate!
        end
      end

      context 'referencing a new user' do
        before do
          config.user_repository = nil_user_repository
        end

        it 'calls the `after_local_user_not_found` callback' do
          expect(config.after_local_user_not_found).to receive(:call).with(cognito_user,
                                                                           pool_identifier).and_call_original
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
