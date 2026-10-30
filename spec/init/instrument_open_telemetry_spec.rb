# frozen_string_literal: true

require 'spec_helper'
require 'opentelemetry/sdk'
require allsearch_path 'init/instrument_open_telemetry'

describe InstrumentOpenTelemetry do
  def mock_sdk
    configurator = instance_double(OpenTelemetry::SDK::Configurator, use: nil)
    opentelemetry_sdk = class_double(OpenTelemetry::SDK)
    allow(opentelemetry_sdk).to receive(:configure).and_yield(configurator)
    opentelemetry_sdk
  end

  it 'configures in production' do
    opentelemetry_sdk = mock_sdk
    instrument = described_class.new(environment: Environment.new({ 'APP_ENV' => 'production' }), opentelemetry_sdk:)
    instrument.call
    expect(opentelemetry_sdk).to have_received(:configure)
  end

  it 'does not configure in development' do
    opentelemetry_sdk = mock_sdk
    instrument = described_class.new(environment: Environment.new, opentelemetry_sdk:)
    instrument.call
    expect(opentelemetry_sdk).not_to have_received(:configure)
  end
end
