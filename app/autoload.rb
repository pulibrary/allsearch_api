# frozen_string_literal: true

# This file is responsible for autoloading our classes and modules
# TODO: before replacing Rails' autoloaders with this, we need to implement the following:
#   * enable reloading in dev when we change a file
#   * enable eager load in staging and prod

require 'zeitwerk'

Loader = Zeitwerk::Loader.new
Loader.push_dir("#{__dir__}/checks")
Loader.push_dir("#{__dir__}/controllers")
Loader.push_dir("#{__dir__}/models")
Loader.push_dir("#{__dir__}/models/concerns")
Loader.push_dir("#{__dir__}/relations")
Loader.push_dir("#{__dir__}/repositories")
Loader.push_dir("#{__dir__}/services")

Loader.inflector.inflect(
  'csv_loading_service' => 'CSVLoadingService',
  'oauth_service' => 'OAuthService',
  'oauth_token_cache' => 'OAuthTokenCache',
  'oauth_token_repository' => 'OAuthTokenRepository'
)

Loader.setup
