# frozen_string_literal: true

ALLSEARCH_AUTOLOAD_DIRECTORIES = [
  'app/checks', 'app/controllers', 'app/models', 'app/models/concerns', 'app/relations', 'app/repositories',
  'app/services'
].freeze

require 'zeitwerk'

# This class is a wrapper around the Listen gem
class FileListener
  def initialize(path_generator: ->(path) { allsearch_path(path) })
    @path_generator = path_generator
  end

  def call
    require 'listen'
    listener = Listen.to(path_generator.call('app')) do |_modified, _added, _removed|
      yield
    end
    listener.start
  end

  private

  attr_reader :path_generator
end

# This class is responsible for autoloading our classes and modules.
# In production and staging, it eagerly loads all the classes and modules so they are ready for use without overhead.
# In test and development, it lazily loads classes and modules, waiting until we actually use them,
#   giving us faster startup.
# In development, it listens for file changes in the app directory.  If there is a change, it will reload the
#   relevant classes and modules.
class Autoloader
  def initialize(
    environment: CURRENT_ENVIRONMENT,
    listener: FileListener.new,
    directories: ALLSEARCH_AUTOLOAD_DIRECTORIES,
    path_generator: ->(path) { allsearch_path(path) }
  )
    @environment = environment
    @path_generator = path_generator
    @directories = directories
    @listener = listener
  end

  def call
    loader
    environment
      .when_deployed { loader.eager_load }
      .when_development do
      listener.call { reload }
    end
  end

  private

  attr_reader :directories, :environment, :path_generator, :listener

  def reload
    environment.when_development { loader.reload }
  end

  def loader
    @loader ||= begin
      new_loader = Zeitwerk::Loader.new
      directories.each { |path| new_loader.push_dir(path_generator.call(path)) }
      new_loader.inflector.inflect(inflections)
      environment.when_development { new_loader.enable_reloading }
      new_loader.setup
      new_loader
    end
  end

  def inflections
    {
      'csv_loading_service' => 'CSVLoadingService',
      'oauth_service' => 'OAuthService',
      'oauth_token_cache' => 'OAuthTokenCache',
      'oauth_token_relation' => 'OAuthTokenRelation',
      'oauth_token_repository' => 'OAuthTokenRepository'
    }
  end
end

Autoloader.new.call
