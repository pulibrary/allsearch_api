# frozen_string_literal: true

# This class is responsible for querying the Summon API
class Summon
  include ActiveModel::API
  include Parsed
  attr_reader :query_terms, :service, :service_response

  def initialize(query_terms:)
    @query_terms = query_terms
    @config = Rails.application.config_for(:allsearch)[:summon]
    @service = 'summon'
    summon = SummonService.new(query_terms: @query_terms)
    @service_response = summon.summon_service_response
  end

  def summon_service_response
    # service = Summon::Service.new(url: @config[:url], access_id: @config[:app_id], secret_key: @config[:key])
    # byebug
    # search = service.search(
    #   's.q' => query_terms,
    #   's.ho' => 't',
    #   's.ps' => 3,
    #   's.secure' => 't',
    #   's.role' => 'authenticated',
    #   's.dailyCatalog' => 't'
    # )
    # byebug

    JSON.parse(search, symbolize_names: true)
  end
end
