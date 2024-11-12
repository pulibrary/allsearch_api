# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Rails.application.config.after_initialize do
  def solr_config_for(service:)
    Rails.application.config_for(:allsearch)[service][:solr]
  end

  HealthMonitor.configure do |config|
    config.cache.configure do |cache_config|
      cache_config.critical = false
    end
    config.database.configure do |database_config|
      database_config.critical = false
    end
    config.file_absence.configure do |file_config|
      file_config.filename = 'public/remove-from-nginx'
    end
    # includes database check by default
    # Include separate Solr check for each service
    solr_services = [:catalog, :dpul, :findingaids, :pulmap]
    solr_services.each do |service|
      config.solr.configure do |c|
        solr_config = solr_config_for(service:)
        c.name = "Solr: #{service}"
        c.url = URI::HTTP.build(host: solr_config[:host],
                                port: solr_config[:port]).to_s
        c.collection = solr_config[:collection]
        c.critical = false
      end
    end
    # Make this health check available at /health
    config.path = :health

    # Notify Honeybadger if there is a failed health check
    config.error_callback = proc do |e|
      unless e.is_a?(HealthMonitor::Providers::FileAbsenceException)
        Rails.logger.error "Health check failed with: #{e.message}"
        Honeybadger.notify(e)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
