# frozen_string_literal: true

class QueryUri
  # :reek:LongParameterList
  def call(query_builder:, user_query: '', uri_class: URI::HTTPS, **options)
    CGI.escape(user_query)
       .then { query_builder.call(it) }
       .then { |query| options.merge({ query: }) }
       .then { uri_class.build it }
  end
end
