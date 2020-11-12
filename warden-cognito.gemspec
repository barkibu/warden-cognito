lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'warden/cognito/version'

Gem::Specification.new do |spec|
  spec.name          = 'warden-cognito'
  spec.version       = Warden::Cognito::VERSION
  spec.authors       = ['Juan F. Pérez']
  spec.email         = ['761794+jguitar@users.noreply.github.com']

  spec.summary       = 'Amazon Cognito authentication for Warden'
  spec.description   = '[Unofficial] Authentication Strategy for Warden to allow Amazon Cognito user sign in and JWT'
  spec.homepage      = 'https://github.com/barkibu/warden-cognito'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/barkibu/warden-cognito'
    spec.metadata['changelog_uri'] = 'https://github.com/barkibu/warden-cognito/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.6.5'

  spec.add_dependency 'activesupport', '~> 6.0'
  spec.add_dependency 'aws-sdk-cognitoidentityprovider', '~> 1.47'
  spec.add_dependency 'dry-auto_inject', '~> 0.6'
  spec.add_dependency 'dry-configurable', '~> 0.9'
  spec.add_dependency 'jwt', '~> 2.1'
  spec.add_dependency 'warden', '~> 1.2'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'pry-byebug', '~> 3.7'
  spec.add_development_dependency 'rack-test', '~> 1.1'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.2'
end
