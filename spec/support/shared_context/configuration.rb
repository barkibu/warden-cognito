# frozen_string_literal: true

shared_context 'configuration' do
  before do
    Warden::Cognito.configure do |config|
      config.user_repository = Fixtures::UserRepo
      config.identifying_attribute = :identifying_attribute
      config.after_local_user_by_credentials_not_found = Fixtures::Callback.after_user_local_not_found_nil
      config.after_local_user_by_token_not_found = Fixtures::Callback.after_user_local_not_found_nil
    end
  end

  let(:config) { Warden::Cognito.config }
  let(:identifying_attribute) { config.identifying_attribute }
end
