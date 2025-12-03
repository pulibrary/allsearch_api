# frozen_string_literal: true

# This class maintains a list of health checks
class CheckList
  def initialize(env)
    @env = env
  end

  # :reek:NestedIterators
  def results
    all_requests
      .map do |name, request|
      request.value.either(
        ->(_success) { { name:, message: '', status: 'OK' } },
        ->(failure_message) { { name:, message: failure_message, status: 'ERROR' } }
      )
    end
  end

  def overall_health
    if critical_requests.any? { |_name, request| request.value.failure? }
      'error'
    else
      'ok'
    end
  end

  private

  attr_reader :env

  def critical_checks
    {
      'remove-from-nginx file is not present' => FileDoesNotExistCheck.new("#{__dir__}/../../public/remove-from-nginx")
    }
  end

  def non_critical_checks
    {
      'Database' => DatabaseCheck.new(db_gateways),
      'Solr: catalog' => solr_check_for_config('catalog'),
      'Solr: dpul' => solr_check_for_config('dpul'),
      'Solr: findingaids' => solr_check_for_config('findingaids'),
      'Solr: pulmap' => solr_check_for_config('pulmap')
    }
  end

  # :reek:FeatureEnvy
  def solr_check_for_config(system)
    config = solr_configs[system]['solr']
    SolrCheck.new(host: config['host'], port: config['port'], collection: config['collection'])
  end

  def all_requests
    @all_requests ||= critical_requests.merge(non_critical_requests)
  end

  def critical_requests
    @critical_requests ||= critical_checks.transform_values { |check| Thread.new { check.call } }
  end

  def non_critical_requests
    @non_critical_requests ||= non_critical_checks.transform_values { |check| Thread.new { check.call } }
  end

  def solr_config_path
    "#{__dir__}/../../config/allsearch.yml"
  end

  def solr_configs
    @solr_configs ||= YAML.safe_load(ERB.new(File.read(solr_config_path)).result, aliases: true)[Rails.env]
  end

  def db_gateways
    env['rom']&.gateways&.values || []
  end
end
