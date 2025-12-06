# frozen_string_literal: true

# Flipper must be required after a database connection is established
require_relative '../db_connection'
begin
  require 'flipper-sequel'
rescue Sequel::Error
  # We may be in a context where the database is not yet available
  # (e.g. rake servers:start)
  nil
end
