require "jwt"
require "warden"

module Warden
  module Cognito
    class Error < StandardError; end
    # Your code goes here...
  end
end

require "warden/cognito/version"
require "warden/cognito/authenticatable_strategie"
require "warden/cognito/token_authenticatable_strategie"
