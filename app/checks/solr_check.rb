# frozen_string_literal: true

# This class is responsible for checking a solr collection to see if it is healthy
class SolrCheck
  include Dry::Monads[:result]

  def initialize(host:, collection:, port: 8983)
    @port = port
    @host = host
    @collection = collection
  end

  def call
    ping_response.bind do |response|
      json = JSON.parse(response.body, symbolize_names: true) if response.code == '200'
      return Success() if response.is_a?(Net::HTTPSuccess) && json[:status].casecmp?('OK')

      Failure("The Solr collection has an invalid status #{ping_uri}")
    end
  end

  private

  attr_reader :port, :host, :collection

  def ping_response
    Success(Net::HTTP.get_response(ping_uri))
  rescue StandardError => error
    Failure(error.message)
  end

  # bearer:disable ruby_lang_http_insecure
  def ping_uri
    URI("http://#{host}:#{port}/solr/#{collection}/admin/ping")
  end
end
