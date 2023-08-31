# frozen_string_literal: true

class ArtMuseum
  include ActiveModel::API
  include Parsed
  attr_reader :query_terms, :service, :service_response

  def initialize(query_terms:)
    @query_terms = query_terms
    @service = 'artmuseum'
    @service_response = art_museum_service_response(query_terms:)
  end

  def art_museum_service_response(query_terms:)
    uri = URI::HTTPS.build(host: 'data.artmuseum.princeton.edu', path: '/search',
                           query: "q=#{query_terms}&type=all&size=3")
    response = Net::HTTP.get(uri)
    JSON.parse(response, symbolize_names: true)
  end

  def number
    service_response.dig(:hits, :total)
  end

  def more_link
    URI::HTTPS.build(host: 'artmuseum.princeton.edu', path: '/search/collections',
                     query: "mainSearch=\"#{query_terms}\"")
  end

  def documents
    @documents ||= service_response.dig(:hits, :hits)
  end

  def id(document:)
    document[:_id]
  end

  def title(document:)
    document.dig(:_source, :displaytitle)
  end

  def creator(document:)
    document.dig(:_source, :displaymaker)
  end

  def publisher(document:)
    # tbd - nothing in the current json that seems relevant
  end

  def type(document:)
    document[:_type]
  end

  def description(document:)
    # tbd - nothing in the current json that seems relevant
  end

  def url(document:)
    URI::HTTPS.build(host: 'artmuseum.princeton.edu', path: "/collections/objects/#{id(document:)}")
  end

  def other_fields(document:)
    doc_keys = [:credit_line, :medium, :dimensions, :primary_image, :object_number]
    parsed_record(document:, doc_keys:)
  end

  def credit_line(document:)
    document.dig(:_source, :creditline)
  end

  def medium(document:)
    document.dig(:_source, :medium)
  end

  def dimensions(document:)
    document.dig(:_source, :dimensions)
  end

  def primary_image(document:)
    document.dig(:_source, :primaryimage)&.first
  end

  def object_number(document:)
    document.dig(:_source, :objectnumber)
  end
end
