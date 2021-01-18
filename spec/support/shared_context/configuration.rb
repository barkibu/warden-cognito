# frozen_string_literal: true

shared_context 'configuration' do
  before do
    Warden::Cognito.configure do |config|
      config.user_repository = Fixtures::UserRepo
      config.identifying_attribute = :identifying_attribute
      config.after_local_user_not_found = Fixtures::Callback.after_user_local_not_found_nil
      config.user_pools = user_pool_configurations
    end
  end

  let(:user_pool_configurations) do
    { "#{pool_identifier}": { region: region, pool_id: pool_id, client_id: client_id } }
  end
  let(:region) { 'EU_WEST_1' }
  let(:pool_id) { 'AWS_COGNITO_USER_POOL_ID' }
  let(:client_id) { 'AWS_COGNITO_CLIENT_ID' }
  let(:pool_identifier) { :myPoolId }
  let(:config) { Warden::Cognito.config }
  let(:identifying_attribute) { config.identifying_attribute }
end
