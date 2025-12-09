# frozen_string_literal: true

require 'forwardable'
require 'dry-monads'

# This class is responsible for querying the Summon API, aka "Articles+"
class Article
  extend Forwardable
  include Parsed
  include Dry::Monads[:maybe]

  attr_reader :query_terms, :service

  def_delegators :service_response, :documents

  def initialize(query_terms:, rom: Rails.application.config.rom)
    @query_terms = query_terms
    summon_config = ALLSEARCH_CONFIGS[:allsearch][:summon]
    @service = Summon::Service.new(access_id: summon_config[:access_id],
                                   secret_key: summon_config[:secret_key])
  end

  # For documentation on query parameters, see https://developers.exlibrisgroup.com/summon/apis/SearchAPI/Query/Parameters/
  def service_response
    service.search(
      's.q': query_terms, # Lucene-style queries
      's.fvf': 'ContentType,Newspaper Article,true', # Excludes newspaper articles
      's.ho': 't', # Princeton holdings only
      's.dym': 't', # Enables Did You Mean functionality
      's.ps': 3 # Limits to three documents in response
    )
  rescue Summon::Transport::TransportError
    handle_summon_authorization_error
  end

  def number
    service_response.record_count
  end

  def more_link
    Some(URI::HTTPS.build(host: 'princeton.summon.serialssolutions.com', path: '/search',
                          query: service_response.query.query_string))
  end

  private

  # :reek:FeatureEnvy
  def handle_summon_authorization_error
    raise AllsearchError.new(problem: 'UPSTREAM_ERROR',
                             msg: 'Could not authenticate to the upstream Summon service')
  end
end
