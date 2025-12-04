# frozen_string_literal: true

require_relative '../environment'
require 'dry-monads'

# This class is responsible for getting relevant
# metadata from the Catalog's JSON
# The document is a Hash
class CatalogDocument < Document
  include SolrDocument
  include Dry::Monads[:maybe]

  def initialize(document:, doc_keys:, environment: Environment.new)
    super(document:, doc_keys:)
    @environment = environment
  end

  private

  attr_reader :environment

  include Holdings

  def service
    'catalog'
  end

  def title
    document[:title_display]
  end

  def creator
    document[:author_display]&.first
  end

  def publisher
    document[:pub_created_display]&.first
  end

  def type
    document[:format]&.first
  end

  def description
    # tbd - nothing in the current json that seems relevant
  end

  def doc_keys
    [:first_barcode, :second_barcode, :first_call_number, :second_call_number, :first_library, :second_library,
     :first_status, :second_status, :online_access_count, :resource_url, :resource_url_label]
  end

  def online_access_count
    ea_count = electronic_access&.count || 0
    portfolio_count = document[:electronic_portfolio_s]&.count || 0
    ea_count + portfolio_count
  end

  def resource_url
    portfolio['url'] || electronic_access&.keys&.first
  end

  def resource_url_label
    return unless should_display_resource_url_label?

    portfolio['title'] || electronic_access&.values&.first&.first || 'Online content'
  end

  def should_display_resource_url_label?
    portfolio.any? || electronic_access.any?
  end

  def portfolio
    @portfolio ||= begin
      portfolio_string = Maybe(document[:electronic_portfolio_s]&.first)
      portfolio_string.fmap { |raw| JSON.parse(raw) }.value_or({})
    end
  end

  def electronic_access
    @electronic_access ||= begin
      electronic_access_string = Maybe(document[:electronic_access_1display])
      electronic_access_string.bind do |raw|
        if raw.strip.empty?
          None()
        else
          Some(JSON.parse(raw))
        end
      end.value_or({})
    end
  end

  def do_not_sanitize_these_fields
    super + [:resource_url]
  end
end
