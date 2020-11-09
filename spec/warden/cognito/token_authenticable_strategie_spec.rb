require 'spec_helper'

RSpec.describe Warden::Cognito::TokenAuthenticatableStrategie do
  let(:jwt_token) { 'FakeJwtToken' }
  let(:headers) { { 'HTTP_AUTHORIZATION' => "Bearer #{jwt_token}" } }
  let(:path) { '/v1/resource' }
  let(:env) { Rack::MockRequest.env_for(path, method: 'GET').merge(headers) }
  let(:strategy) { described_class.new(env) }
  let(:user) { create(:user) }
  let(:kb_uuid) { user.id }
  let(:decoded_token) do
    [
      {
        # Faker::PhoneNumber.cell_phone_in_e164 can throw an issue
        # https://github.com/carr/phone/issues/94
        'phone_number' => '+6789035122371',
        'custom:kb_uuid' => kb_uuid
      }
    ]
  end

  before do
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
      context 'referencing an existing (local) user' do
        it 'succeeds with the user instance' do
          expect(strategy).to receive(:success!).with(user)
          strategy.authenticate!
        end
      end

      context 'referencing a new user' do
        let(:kb_uuid) { -1 }

        it 'succeeds with a new user created' do
          expect(strategy).to receive(:success!)
          expect { strategy.authenticate! }.to change(User, :count).by 1
        end
      end
    end
  end
end
