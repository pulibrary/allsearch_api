# frozen_string_literal: true

require 'opentelemetry/sdk'

class InstrumentOpenTelemetry
  def initialize(environment: CURRENT_ENVIRONMENT, logger: ALLSEARCH_LOGGER, opentelemetry_sdk: OpenTelemetry::SDK)
    @environment = environment
    @logger = logger
    @opentelemetry_sdk = opentelemetry_sdk
  end

  def call
    environment.when_deployed do
      require_otel_gems
      configure_otel
    end
  end

  private

  def require_otel_gems
    require 'opentelemetry/exporter/otlp'
    require 'opentelemetry/instrumentation/net/http'
    require 'opentelemetry/instrumentation/pg'
    require 'opentelemetry/instrumentation/rack'
  end

  def configure_otel
    OpenTelemetry.logger = logger

    opentelemetry_sdk.configure do |c|
      c.use 'OpenTelemetry::Instrumentation::Net::HTTP'
      c.use 'OpenTelemetry::Instrumentation::PG'
      c.use 'OpenTelemetry::Instrumentation::Rack'
    end
  end

  attr_reader :environment, :logger, :opentelemetry_sdk
end

InstrumentOpenTelemetry.new.call
