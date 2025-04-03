require 'spec_helper'

RSpec.describe Warden::Cognito::RefreshableTokenDecoder do
  include_context 'configuration'

  let(:issuer) { "https://cognito-idp.#{region}.amazonaws.com/#{pool_id}" }
  let(:decoded_token) do
    [
      {
        'sub' => 'CognitoUserId',
        'iss' => issuer
      }
    ]
  end
  let(:client_id_pool_a) { 'AWS Cognito Client ID Specific Pool' }
  let(:user_pool_configurations) do
    {
      pool_a: { region: region, pool_id: 'another_pool_id', client_id: client_id_pool_a },
      "#{pool_identifier}": { region: region, pool_id: pool_id, client_id: client_id }
    }
  end

  let(:pool_identifier_passed) { pool_identifier }
  let(:jwt_token) { 'FakeJwtToken' }
  let(:refresh_token) { 'FakeRefreshToken' }

  subject(:decoder) { described_class.new(jwt_token, refresh_token, -> {}, pool_identifier_passed) }

  describe '#new' do
    context 'with a pool identifier specified' do
      context 'when an associated configuration exists' do
        it 'finds the associated JwkLoader' do
          expect(decoder.pool_identifier).to eq(pool_identifier)
        end
      end

      context 'when no associated configuration exists' do
        let(:pool_identifier_passed) { :non_configured_pool }
        it 'raises an exception' do
          expect { decoder }.to raise_exception JWT::InvalidIssuerError
        end
      end
    end

    context 'with no pool identifier specified' do
      let(:pool_identifier_passed) { nil }

      context 'when an associated configuration exists' do
        before do
          allow(JWT).to receive(:decode).with(jwt_token, any_args).and_return(decoded_token)
        end

        it 'finds the associated JwkLoader' do
          expect(decoder.pool_identifier).to eq(pool_identifier)
        end
      end

      context 'when no associated configuration exists' do
        let(:issuer) { 'http://google_issued_token.issuer/url' }

        it 'raises an exception' do
          expect { decoder }.to raise_exception JWT::InvalidIssuerError
        end
      end
    end
  end

  describe '#validate!' do
    context 'with a valid access token' do
      before do
        allow(JWT).to receive(:decode).with(jwt_token, any_args).and_return(decoded_token)
      end

      it 'returns true' do
        expect(decoder.validate!).to be true
      end
    end

    context 'with an invalid access token' do
      before do
        allow(JWT).to receive(:decode).with(jwt_token, nil, true, any_args).and_raise(JWT::ExpiredSignature)
      end

      context 'with a valid refresh token' do
        before do
          client = double
          exchange_token_response = OpenStruct.new(authentication_result: OpenStruct.new(access_token: jwt_token))
          allow(decoder).to receive(:cognito_client).and_return(client)
          allow(JWT).to receive(:decode).with(jwt_token, nil, false).and_return decoded_token
          allow(client).to receive(:exchange_token)
            .and_return(exchange_token_response)
          allow(JWT).to receive(:decode).with(jwt_token, any_args).and_return(decoded_token)
        end

        it 'returns true' do
          expect(decoder.validate!).to be true
        end
      end

      context 'with an invalid refresh token' do
        before do
          client = double
          allow(decoder).to receive(:cognito_client).and_return(client)
          allow(JWT).to receive(:decode).with(jwt_token, nil, false).and_return decoded_token
          allow(client).to receive(:exchange_token)
            .and_raise(Aws::CognitoIdentityProvider::Errors::ExpiredCodeException.new('', ''))
        end

        it 'raises an ExpiredToken error' do
          expect { decoder.validate! }.to raise_exception JWT::ExpiredSignature
        end
      end

      context 'with a nil refresh token' do
        let(:refresh_token) { nil }

        it 'raises an ExpiredToken error' do
          expect { decoder.validate! }.to raise_exception JWT::ExpiredSignature
        end
      end
    end
  end
end
