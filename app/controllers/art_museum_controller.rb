# frozen_string_literal: true

class ArtMuseumController < RackServiceController
  attr_reader :query

  def initialize
    super
    @service = ArtMuseum
  end

  def self.call(_env)
    controller = ArtMuseumController.new
    @query = controller.service.new(query_terms: query_params)
    [200, { 'Content-Type' => 'application/json; charset=utf-8' }, [query.our_response.to_json]]
  end
end
