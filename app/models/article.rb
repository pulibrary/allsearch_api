# frozen_string_literal: true

require 'dry-monads'

# This class is responsible for querying the Summon API, aka "Articles+"
class Article
  include Dry::Monads[:maybe]

  def our_response(query_terms:)
    service_response = service_search(query_terms:)
    {
      number: service_response.record_count,
      records: service_response.documents.map { |document| document_class.new(document:, doc_keys:).to_h },
      more: more_link(service_response:)
    }.compact.to_json
  end

  # For documentation on query parameters, see https://developers.exlibrisgroup.com/summon/apis/SearchAPI/Query/Parameters/
  def service_search(query_terms:)
    service.search(
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

  private

  def more_link(service_response:)
    query_uri.call(host: 'princeton.summon.serialssolutions.com', path: '/search',
                   query_builder: ->(_query) { service_response.query.query_string })
  end

  def query_uri = @query_uri ||= QueryUri.new

  def service
    @service ||= ALLSEARCH_CONFIGS[:allsearch][:summon]
                 .then { Summon::Service.new(access_id: it[:access_id], secret_key: it[:secret_key]) }
  end

  def doc_keys = [:title, :creator, :publisher, :id, :type, :description, :url, :other_fields]

  def document_class = ArticleDocument

  # :reek:FeatureEnvy
  def handle_summon_authorization_error
    raise AllsearchError.new(problem: 'UPSTREAM_ERROR',
                             msg: 'Could not authenticate to the upstream Summon service')
  end
end
