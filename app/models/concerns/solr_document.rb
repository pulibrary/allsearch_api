# frozen_string_literal: true

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
    Rails.application.config_for(:allsearch)[service][:subdomain]
  end
end
