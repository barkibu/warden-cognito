require 'spec_helper'

RSpec.describe Warden::Cognito::AuthenticatableStrategie do
  let(:scope) { :v2_user }
  let(:strategy) { described_class.new(env, scope) }
  let(:path) { '/v1/resource' }
  let(:email) { 'test@example.com' } # user.email
  let(:password) { 'MyPassW0r1' } # user.password 
  # let(:user) { create(:user) }
  let(:params) do
    {
      v2_user: {
        email: email,
        password: password
      }
    }
  end
  let(:env) { Rack::MockRequest.env_for(path, method: 'GET', params: params) }

  describe '.valid?' do
    it 'returns true for sign in requests' do
      expect(strategy.valid?).to be_truthy
    end

    context 'with a non-sign in requests' do
      let(:params) { { foo: 'bar' } }

      it 'returns false' do
        expect(strategy.valid?).to be_falsey
      end
    end
  end

  describe '.authenticate' do
    let(:client) { double 'Client' }
    before do
      allow(Aws::CognitoIdentityProvider::Client).to receive(:new).and_return client
    end

    context 'with wrong credentials' do
      let(:not_authorized_exception) do
        Aws::CognitoIdentityProvider::Errors::NotAuthorizedException.new(nil,
                                                                         'Invalid Login')
      end

      before do
        allow(client).to receive(:initiate_auth).and_raise not_authorized_exception
      end

      it 'call fail' do
        expect(strategy).to receive(:fail).with(:invalid_login)
        strategy.authenticate!
      end
    end

    context 'with right credentials' do
      before do
        allow(client).to receive(:initiate_auth).and_return true
      end

      # it 'call success with an existing user' do
      #   expect(strategy).to receive(:success!).with(user)
      #   strategy.authenticate!
      # end
      #
      # context 'with new user' do
      #   let(:user) { build(:user) }
      #   it 'call success with a new persisted user' do
      #     expect(strategy).to receive(:success!) do |authenticated_user|
      #       expect(authenticated_user.email).to eq(user.email)
      #     end
      #     expect { strategy.authenticate! }.to change { User.count }.by(1)
      #   end
      # end
    end
  end
end
