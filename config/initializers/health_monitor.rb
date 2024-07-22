# frozen_string_literal: true

Rails.application.config.after_initialize do
  HealthMonitor.configure do |config|
    config.cache
    # includes database check by default
    config.add_custom_provider(SolrStatus)
    # Make this health check available at /health
    config.path = :health

    # Notify Honeybadger if there is a failed health check
    config.error_callback = proc do |e|
      Rails.logger.error "Health check failed with: #{e.message}"
      Honeybadger.notify(e)
    end
  end
end
