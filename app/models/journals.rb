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
    Some(URI::HTTPS.build(host: "#{service_subdomain}.princeton.edu", path: '/catalog',
                          query: "q=#{query_terms}&f[format][]=Journal&search_field=all_fields"))
  end
end
