# frozen_string_literal: true

class QueryUri
  def initialize(query_builder:, user_query: '', uri_class: URI::HTTPS, **options)
    @user_query = user_query
    @query_builder = query_builder
    @uri_class = uri_class
    @options = options
  end

  def call
    uri_class.build(build_arguments)
  end

  private

  def build_arguments
    options.merge({ query: })
  end

  def query
    CGI.escape(user_query)
       .then { |escaped| query_builder.call(escaped) }
  end
  attr_reader :uri_class, :user_query, :query_builder, :options
end
