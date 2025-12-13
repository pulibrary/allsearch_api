# frozen_string_literal: true

# These helpers create a full Rack application for testing

require 'rack'
require 'rack/test'

ALLSEARCH_RACK_APP = Rack::Builder.parse_file(allsearch_path('config.ru').to_s)

module RackTestHelpers
  include Rack::Test::Methods

  def app
    ALLSEARCH_RACK_APP
  end
end
