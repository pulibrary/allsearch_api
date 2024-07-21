# frozen_string_literal: true

class SolrStatus < HealthMonitor::Providers::Base
  def check!
    failed_solrs = []
    status_uris.each do |status_uri|
      response = Net::HTTP.get_response(status_uri)
      json = JSON.parse(response.body)
      success = json['responseHeader']['status'].zero?
      failed_solrs << status_uri unless success
    end
    raise "The solr has an invalid status #{failed_solrs.join(', ')}" unless failed_solrs.empty?
  end

  # Right now all of our services are on solr 8,
  # but eventually they will be split between solr 8 and solr 9
  def solr_services_configs
    Rails.application.config_for(:allsearch).select { |_k, v| v.keys.include?(:solr) }
  end

  def status_uris
    solr_services_configs.map do |_name, config|
      solr_config = config[:solr]
      URI::HTTP.build(host: solr_config[:host],
                      port: solr_config[:port],
                      path: '/solr/admin/cores',
                      query: 'action=STATUS')
    end.uniq.compact
  end
end
