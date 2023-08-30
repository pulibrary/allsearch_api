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
    doc_hash = {}
    # The method name must match the key name, and must take the keyword argument `document:`
    doc_keys.each do |key|
      val = send(key, document:)
      doc_hash[key] = val if val
    end
    doc_hash
  end

  def our_response
    {
      number:,
      more: more_link,
      records: parsed_records(documents:)
    }.to_json
  end
end
