# frozen_string_literal: true

class Journals < Catalog
  def search_query_builder
    lambda { |query|
      "q=#{query}&rows=3&facet=false&fl=#{solr_fields.join(',')}&sort=#{solr_sort}&fq=format:Journal"
    }
  end

  def more_link(query_terms:)
    Some(query_uri.call(
           host: "#{subdomain}.princeton.edu",
           path: '/catalog',
           user_query: query_terms,
           query_builder: ->(query) { "q=#{query}&f[format][]=Journal&search_field=all_fields" }
         ))
  end
end
