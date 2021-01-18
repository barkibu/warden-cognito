# frozen_string_literal: true

shared_context 'configuration' do
  before do
    Warden::Cognito.configure do |config|
      config.user_repository = Fixtures::UserRepo
      config.identifying_attribute = :identifying_attribute
      config.after_local_user_not_found = Fixtures::Callback.after_user_local_not_found_nil
      config.user_pools = { "#{pool_identifier}": { region: 'EU_WEST_1', pool_id: 'Cognito UserPool Id',
                                                    client_id: 'Cognito Client Id' } }
    end
  end

  let(:pool_identifier) { :myPoolId }
  let(:config) { Warden::Cognito.config }
  let(:identifying_attribute) { config.identifying_attribute }
end
