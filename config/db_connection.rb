# frozen_string_literal: true

require 'erb'
require 'sequel'
require 'yaml'

path = "#{__dir__}/database.yml"
db_config = YAML.safe_load(ERB.new(File.read(path)).result, aliases: true)[Rails.env]

DB = Sequel.postgres(db_config['database'], user: db_config['username'], password: db_config['password'],
                                            host: db_config['host'], port: db_config['port'])
