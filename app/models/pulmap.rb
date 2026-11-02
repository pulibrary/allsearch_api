# frozen_string_literal: true

require 'dry-monads'

# This class is responsible for querying maps.princeton.edu (aka Pulmap)
class Pulmap
  include Dry::Monads[:maybe]

  attr_reader :allsearch_config

  def initialize(allsearch_config: ALLSEARCH_CONFIGS[:allsearch])
    @allsearch_config = allsearch_config
  end

  def our_response(query_terms:)
    service_response = client.query(query_terms:)
    {
      number: service_response.dig(:response, :numFound),
      records: service_response.dig(:response, :docs).map { |document| document_class.new(document:, doc_keys:).to_h },
      more: more_link(query_terms:).value_or(nil)
    }.compact.to_json
  end

  private

  def client = @client ||= SolrClient.new(solr_config:, query_builder: search_query_builder)
  def solr_config = allsearch_config[:pulmap][:solr]
  def subdomain = allsearch_config[:pulmap][:subdomain]

  def search_query_builder
    lambda do |query|
      query = "q=#{query}&rows=3&facet=false&fl=#{solr_fields.join(',')}&sort=#{solr_sort}"
      query = "#{query}&#{extra_solr_params}" if extra_solr_params
      query
    end
  end

  def extra_solr_params; end

  def more_link(query_terms:)
    Some(query_uri.call(
           host: "#{subdomain}.princeton.edu",
           path: '/catalog',
           user_query: query_terms,
           query_builder: ->(query) { "q=#{query}&search_field=all_fields" }
         ))
  end

  def query_uri = @query_uri ||= QueryUri.new

  def doc_keys = [:title, :creator, :publisher, :id, :type, :description, :url, :other_fields]
  def document_class = PulmapDocument

  def solr_fields
    %w[layer_slug_s dc_title_s dc_creator_sm dc_publisher_s dc_format_s dc_description_s dc_rights_s
       layer_geom_type_s]
  end

  def solr_sort = 'score desc'
end
