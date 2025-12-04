# frozen_string_literal: true

require_relative '../../environment'

# This module helps classes create documents based on Solr
module SolrDocument
  private

  def id
    document[:id]
  end

  def url
    "https://#{service_subdomain}.princeton.edu/catalog/#{id}"
  end

  def service_subdomain
    environment.config(:allsearch)[service.to_sym][:subdomain]
  end
end
