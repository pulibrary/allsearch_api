# frozen_string_literal: true

module Parsed
  extend ActiveSupport::Concern

  def parsed_records(documents:)
    documents.map do |document|
      doc_keys = [:title, :creator, :publisher, :id, :type, :description, :url, :other_fields]
      parsed_record(document:, doc_keys:)
    end
  end

  def parsed_record(document:, doc_keys:)
    document_class = "#{self.class}Document".constantize
    document_class.new(json: document, doc_keys:).to_h
  end

  def our_response
    {
      number:,
      more: more_link,
      records: parsed_records(documents:)
    }.to_json
  end
end
