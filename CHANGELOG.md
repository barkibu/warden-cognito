# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.3]
- Improve test helpers to include `jti` and `exp` claims and accept user-supplied claims.

## [0.3.2]
- Fix - specify region on scoped aws client

## [0.3.1]
- Allow selection of `user_pool` when generating a jwt through the test helper

## [0.3.0]
- **Breaking Changes**: Configuration explicitly moved to `user_pools` object

## [0.2.3]
- Require the HTTP dependency

## [0.2.2]
- Fix missing HTTP dependency

## [0.2.1]
- Fix rspec dependency in implementation

## [0.2.0]
- Extended exposed API
- TestHelpers utils
- Add Travis setup

## [0.1.0]

- Scratching the gem

[Unreleased]: https://github.com/barkibu/warden-cognito/compare/v0.3.3...HEAD
[0.3.3]: https://github.com/barkibu/warden-cognito/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/barkibu/warden-cognito/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/barkibu/warden-cognito/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/barkibu/warden-cognito/compare/v0.2.3...v0.3.0
[0.2.3]: https://github.com/barkibu/warden-cognito/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/barkibu/warden-cognito/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/barkibu/warden-cognito/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/barkibu/warden-cognito/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/barkibu/warden-cognito/releases/tag/v0.1.0
