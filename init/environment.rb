# frozen_string_literal: true

class Environment
  def initialize(vars = ENV)
    @vars = vars
  end

  def name
    vars['RAILS_ENV'] || 'development'
  end

  def config(config_filename)
    config_filepath = allsearch_path("config/#{config_filename}.yml")
    YAML.safe_load(ERB.new(config_filepath.read).result, aliases: true, symbolize_names: true)[name.to_sym]
  end

  def when_development
    yield if name == 'development'
    self
  end

  def when_deployed
    yield if %w[production staging].include? name
    self
  end

  private

  attr_reader :vars
end

CURRENT_ENVIRONMENT = Environment.new
