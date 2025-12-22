# frozen_string_literal: true

require 'dry-monads'

class Journals < Catalog
  include Dry::Monads[:maybe]

  def extra_solr_params
    'fq=format:Journal'
  end

  def document_class
    CatalogDocument
  end

  def more_link
    Some(QueryUri.new(
      host: "#{service_subdomain}.princeton.edu",
      path: '/catalog',
      user_query: query_terms,
      query_builder: lambda { |query_terms|
        "q=#{query_terms}&f[format][]=Journal&search_field=all_fields"
      }
    ).call)
  end
end
