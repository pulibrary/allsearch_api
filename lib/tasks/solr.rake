# frozen_string_literal: true

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
end
