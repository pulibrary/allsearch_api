# frozen_string_literal: true

# This module helps classes parse API responses
module Parsed
  extend ActiveSupport::Concern

  def parsed_records(documents:)
    documents.map do |document|
      doc_keys = [:title, :creator, :publisher, :id, :type, :description, :url, :other_fields]
      parsed_record(document:, doc_keys:)
    end
  end

  def parsed_record(document:, doc_keys:)
    document_class.new(document:, doc_keys:).to_h
  end

  def our_response
    hash = {
      number:,
      records: parsed_records(documents:)
    }
    hash[:more] = more_link if more_link.present?
    hash.to_json
  end

  def document_class
    @document_class ||= "#{self.class}Document".constantize
  end
end
