require 'spec_helper'

RSpec.describe Warden::Cognito::TokenDecoder do
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

  subject(:decoder) { described_class.new(jwt_token, pool_identifier_passed) }
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
end
