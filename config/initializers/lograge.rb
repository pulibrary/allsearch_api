# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = true

  # We are asking here to log in RAW (which are actually ruby hashes).
  # The Ruby logging is going to take care of the JSON formatting.
  config.lograge.formatter = Lograge::Formatters::Logstash.new
end
