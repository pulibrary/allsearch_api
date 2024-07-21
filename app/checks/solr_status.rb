# frozen_string_literal: true

class SolrStatus < HealthMonitor::Providers::Base
  def check!
    response = Net::HTTP.get_response(status_uri)
    json = JSON.parse(response.body)
    raise "The solr has an invalid status #{status_uri}" if json['responseHeader']['status'] != 0
  end

  # We will want to be able to check both solr8 and solr9 cores
  # Right now we're checking "whatever dpul's host is"
  def solr_config
    Rails.application.config_for(:allsearch)[:dpul][:solr]
  end

  def status_uri
    URI::HTTP.build(host: solr_config[:host],
                    port: solr_config[:port],
                    path: '/solr/admin/cores',
                    query: 'action=STATUS')
  end
end
