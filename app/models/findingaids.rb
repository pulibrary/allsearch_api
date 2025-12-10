# frozen_string_literal: true

# This class is responsible for querying Findingaids (aka PULFAlight)
class Findingaids
  include Parsed
  include Solr

  attr_reader :query_terms, :service, :service_response, :allsearch_config

  def initialize(query_terms:, allsearch_config: ALLSEARCH_CONFIGS[:allsearch])
    @query_terms = query_terms
    @allsearch_config = allsearch_config
    @service = 'findingaids'
    @service_response = solr_service_response
  end

  def solr_fields
    %w[id collection_ssm creator_ssm level_ssm abstract_ssm
       repository_ssm extent_ssm accessrestrict_ssm normalized_date_ssm]
  end

  def solr_sort
    'score desc, title_sort asc'
  end

  def extra_solr_params
    'fq=level_ssm:collection'
  end
end
