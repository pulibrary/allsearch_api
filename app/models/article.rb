# frozen_string_literal: true

require 'forwardable'
require 'dry-monads'

# This class is responsible for querying the Summon API, aka "Articles+"
class Article
  extend Forwardable

  include Dry::Monads[:maybe]

  attr_reader :query_terms, :service

  def initialize(query_terms:)
    @query_terms = query_terms
    summon_config = ALLSEARCH_CONFIGS[:allsearch][:summon]
    @service = Summon::Service.new(access_id: summon_config[:access_id],
                                   secret_key: summon_config[:secret_key])
  end

  def our_response
    {
      number: service_response.record_count,
      records: service_response.documents.map { |document| document_class.new(document:, doc_keys:).to_h },
      more: more_link
    }.compact.to_json
  end

  # For documentation on query parameters, see https://developers.exlibrisgroup.com/summon/apis/SearchAPI/Query/Parameters/
  def service_response
    @service_response ||= service.search(
      's.q': query_terms, # Lucene-style queries
      's.fvf': 'ContentType,Newspaper Article,true', # Excludes newspaper articles
      's.ho': 't', # Princeton holdings only
      's.dym': 't', # Enables Did You Mean functionality
      's.ps': 3, # Limits to three documents in response
      's.include.ft.matches': 't' # Include full text matches
    )
  rescue Summon::Transport::TransportError
    handle_summon_authorization_error
  end

  def more_link
    QueryUri.new.call(host: 'princeton.summon.serialssolutions.com', path: '/search',
                      query_builder: ->(_query) { service_response.query.query_string })
  end

  private

  def doc_keys = [:title, :creator, :publisher, :id, :type, :description, :url, :other_fields]

  def document_class = ArticleDocument

  # :reek:FeatureEnvy
  def handle_summon_authorization_error
    raise AllsearchError.new(problem: 'UPSTREAM_ERROR',
                             msg: 'Could not authenticate to the upstream Summon service')
  end
end
