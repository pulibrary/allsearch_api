# frozen_string_literal: true

require_relative 'allsearch_configs'
require 'erb'
require 'sequel'
require 'yaml'

begin
  db_config = ALLSEARCH_CONFIGS[:database]
  DB = Sequel.postgres(db_config[:database], user: db_config[:username], password: db_config[:password],
                                             host: db_config[:host], port: db_config[:port])
rescue StandardError
  nil
end
