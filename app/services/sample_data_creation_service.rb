# frozen_string_literal: true

class SampleDataCreationService
  def initialize(solr_collection:, filename:, query: 'cats')
    @solr_collection = solr_collection
    @query = query
    @file_path = Rails.root.join('sample-data', filename)
  end

  def create
    file_path.write(docs.to_json)
  end

  private

  attr_reader :file_path, :query, :solr_collection

  def docs
    @docs ||= begin
      response = Net::HTTP.get(uri)
      parsed = JSON.parse(response, symbolize_names: true)[:response][:docs]
      parsed.map do |document|
        document.except(:hashed_id_ssi, :solr_bboxtype, :timestamp, :_version_)
      end
    end
  end

  def uri
    URI.parse "http://localhost:7872/solr/#{solr_collection}/select?q=#{query}&rows=5&facet=false&fl=*"
  end
end
