# frozen_string_literal: true

require 'rails_helper'

# This file defines a DSL that both generates an OpenAPI (aka Swagger) Spec for this application
# and runs RSpec assertions to confirm that the OpenAPI Spec is accurate.  The DSL is extremely
# influenced by RSwag (https://github.com/rswag/rswag), but this implementation does not rely
# on Rails and has the openapi_ prefix throughout.
# To regenerate the OpenAPI spec, run `bundle exec rake openapi:generate` or
# `GENERATE_OPEN_API_SPECS=true bundle exec rspec`

class OpenAPISpecGenerator
  def register_path(path)
    paths[path] ||= {}
  end

  def register_parameter(path, parameter)
    paths[path]['parameters'] ||= []
    paths[path]['parameters'].push parameter
  end

  def register_get(path, get)
    paths[path]['get'] ||= {}
    paths[path]['get'].merge! get
  end

  def register_response(path, status_code, response)
    paths[path]['get']['responses'] ||= {}
    paths[path]['get']['responses'][status_code] ||= {}
    paths[path]['get']['responses'][status_code].merge! response
  end

  def register_content(path, status_code, content)
    paths[path]['get']['responses'][status_code]['content'] = { 'application/json' => { 'example' => content } }
  end

  # rubocop:disable Metrics/MethodLength
  def to_yaml
    {
      'openapi' => '3.1.1',
      'info' => {
        'title' => 'Allsearch API',
        'description' => 'Backend API for allsearch.princeton.edu',
        'version' => 'v1'
      },
      'paths' => paths,
      'servers' => [
        { 'url' => 'https://allsearch-api.princeton.edu' },
        { 'url' => 'https://allsearch-api-staging.princeton.edu' }
      ]
    }.to_yaml
  end
  # rubocop:enable Metrics/MethodLength

  def paths
    @paths ||= {}
  end
end
OPENAPI_GENERATOR = OpenAPISpecGenerator.new

def openapi_path(url_path, ...)
  OPENAPI_GENERATOR.register_path(url_path)
  describe(url_path, ...)
end

def openapi_parameter(hash)
  OPENAPI_GENERATOR.register_parameter(metadata[:description], hash)
end

def openapi_get(hash, ...)
  begin
    OPENAPI_GENERATOR.register_get(metadata[:description], hash)
  rescue StandardError
    raise 'Could not find the relevant path for this openapi_get. ' \
          'Please make sure it is nested directly within an openapi_path block'
  end
  describe(hash['summary'], ...)
end

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
def openapi_response(code, description, query_parameters = {})
  path = metadata[:parent_example_group][:description]
  begin
    OPENAPI_GENERATOR.register_response(path, code, { 'description' => description })
  rescue StandardError
    raise 'could not add response to OpenAPI documentation, ' \
          'please make sure that openapi_response is nested immediately within an openapi_get block'
  end
  url = query_parameters.reduce(metadata[:description]) do |url_with_placeholders, (placeholder, value)|
    url_with_placeholders.gsub("{#{placeholder}}", value)
  end
  it "returns the expected response code #{code} with query params #{query_parameters}" do
    get url
    expect(response.code).to eq code
    OPENAPI_GENERATOR.register_content(path, code, JSON.parse(response.body))
  end

  # Run any additional tests specified in the block
  yield url if block_given?
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength

if ENV['GENERATE_OPEN_API_SPECS'] == 'true'
  RSpec.configure do |config|
    config.after(:suite) do
      File.open(allsearch_path('swagger/v1/swagger.yaml'), 'w') do |file|
        file.puts OPENAPI_GENERATOR.to_yaml
      end
    end
  end
end
