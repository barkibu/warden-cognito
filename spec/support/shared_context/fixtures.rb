# frozen_string_literal: true

shared_context 'fixtures' do
  let(:user_repository) { Fixtures::UserRepo }
  let(:nil_user_repository) { Fixtures::NilUserRepo }
  let(:user) { Fixtures::User.instance }

  StubCognitoUser = Struct.new(:username, :user_attributes)
  AttributeType = Struct.new(:name, :value)
  let(:local_identifier) { 'kb_uuid' }
  let(:cognito_user) do
    StubCognitoUser.new('jmj@barkibu.com',
                        [AttributeType.new('locale', 'es'),
                         AttributeType.new('identifying_attribute', local_identifier)])
  end
end
