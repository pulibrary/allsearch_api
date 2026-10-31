# frozen_string_literal: true

require 'dry-monads'

# This class is responsible for querying the Catalog
class Catalog
  include Dry::Monads[:maybe]

  attr_reader :allsearch_config

  def initialize(allsearch_config: ALLSEARCH_CONFIGS[:allsearch])
    @allsearch_config = allsearch_config
  end

  def our_response(query_terms:)
    service_response = solr_client.query(query_terms:)
    {
      number: service_response.dig(:response, :numFound),
      records: service_response.dig(:response, :docs).map { |document| document_class.new(document:, doc_keys:).to_h },
      more: more_link(query_terms:).value_or(nil)
    }.compact.to_json
  end

  private

  def solr_client = @solr_client ||= SolrClient.new(solr_config:, query_builder: search_query_builder)
  def solr_config = allsearch_config[:catalog][:solr]
  def subdomain = allsearch_config[:catalog][:subdomain]

  def search_query_builder = ->(query) { "q=#{query}&rows=3&facet=false&fl=#{solr_fields.join(',')}&sort=#{solr_sort}" }

  def solr_fields
    %w[id title_display author_display pub_created_display format holdings_1display
       electronic_portfolio_s electronic_access_1display]
  end

  def solr_sort = 'score desc, pub_date_start_sort desc, title_sort asc'

  def more_link(query_terms:)
    Some(query_uri.call(
           host: "#{subdomain}.princeton.edu",
           path: '/catalog',
           user_query: query_terms,
           query_builder: ->(query) { "q=#{query}&search_field=all_fields" }
         ))
  end

  def query_uri = @query_uri ||= QueryUri.new

  def document_class = CatalogDocument

  def doc_keys = [:title, :creator, :publisher, :id, :type, :description, :url, :other_fields]
end
