# frozen_string_literal: true

# :reek:MissingSafeMethod { exclude: [ check! ] }
class SolrStatus < HealthMonitor::Providers::Base
  def check!
    Solr.status_uris.each do |status_uri|
      check_solr_response(status_uri)
    end
    raise "The solr has an invalid status #{failed_solrs.join(', ')}" unless failed_solrs.empty?
  end

  def check_solr_response(status_uri)
    response = Net::HTTP.get_response(status_uri)
    json = JSON.parse(response.body)
    success = json['responseHeader']['status'].zero?
    failed_solrs << status_uri unless success
  end

  def failed_solrs
    @failed_solrs ||= []
  end
end
