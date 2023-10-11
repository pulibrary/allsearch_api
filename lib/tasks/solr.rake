# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :solr do
  desc 'Update solr configs'
  task update_configs: :environment do
    `mkdir -p solr`
    `rm -rf pul_solr-main solr/solr_configs`
    `wget https://github.com/pulibrary/pul_solr/archive/refs/heads/main.zip`
    `unzip main.zip`
    `mv pul_solr-main/solr_configs solr/`
    `rm -rf pul_solr-main main.zip`
  end

  desc "Load each service's sample data from the sample-data directory"
  task load_sample_data: :environment do |_task, _args|
    %w[catalog dpul findingaids pulmap].each do |service|
      system("rake solr:load_sample_data_file[#{service},#{service}.json]")
    end
  end

  desc 'Load an arbitrary sample data file from the sample-data directory'
  task :load_sample_data_file, [:service, :filename] => :environment do |_task, args|
    lando_host = ENV.fetch("lando_#{args.service}_solr_conn_host", nil)
    lando_port = ENV.fetch("lando_#{args.service}_solr_conn_port", nil)
    lando_url = "http://#{lando_host}:#{lando_port}/solr/#{args.service}/update?commit=true"
    `curl -X POST -H 'Content-Type: application/json' \
      '#{lando_url}' --data-binary @sample-data/#{args.filename}`
  end

  desc 'Create new sample data file from staging solr'
  task :create_sample_data, [:query, :solr_collection, :filename] => :environment do |_task, args|
    args.with_defaults(query: 'cats', solr_collection: 'catalog-alma-staging', filename: 'catalog.json')
    SampleDataCreationService.new(query: args.query, solr_collection: args.solr_collection,
                                  filename: args.filename).create
    puts "Searched #{args.solr_collection} for #{args.query} and wrote the results to #{args.filename}"
  rescue Errno::ECONNREFUSED
    puts 'Please set up a tunnel before running this rake task:'
    puts '`ssh -L 7872:localhost:8983 pulsys@lib-solr-staging6`'
  end
end
# rubocop:enable Metrics/BlockLength
