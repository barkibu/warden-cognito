# frozen_string_literal: true

shared_context 'fixtures' do
  let(:user_repository) { Fixtures::UserRepo }
  let(:nil_user_repository) { Fixtures::NilUserRepo }
  let(:user) { Fixtures::User.instance }
end
