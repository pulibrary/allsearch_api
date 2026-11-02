# frozen_string_literal: true

require 'dry-monads'

# This class is responsible for querying DPUL
class Dpul
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
  def solr_config = allsearch_config[:dpul][:solr]
  def subdomain = allsearch_config[:dpul][:subdomain]

  def search_query_builder
    lambda do |query|
      "q=#{query}&rows=3&facet=false&fl=#{solr_fields.join(',')}&sort=#{solr_sort}&#{solr_group_params}"
    end
  end

  def solr_group_params
    'group=true&group.main=true&group.limit=1&group.field=content_metadata_iiif_manifest_field_ssi&group.facet=true'
  end

  def solr_fields
    %w[id readonly_title_ssim readonly_creator_ssim readonly_publisher_ssim readonly_format_ssim
       readonly_collections_tesim]
  end

  def solr_sort = 'score desc'

  def more_link(query_terms:)
    Some(query_uri.call(
           host: "#{subdomain}.princeton.edu",
           path: '/catalog',
           user_query: query_terms,
           query_builder: ->(query) { "q=#{query}&search_field=all_fields" }
         ))
  end

  def query_uri = @query_uri ||= QueryUri.new

  def document_class = DpulDocument
  def doc_keys = [:title, :creator, :publisher, :id, :type, :description, :url, :other_fields]
end
