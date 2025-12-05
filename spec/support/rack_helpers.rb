# frozen_string_literal: true

require 'rack'
require 'rack/test'

ALLSEARCH_RACK_APP = Rack::Builder.parse_file(allsearch_path('config.ru').to_s)

module RackTestHelpers
  include Rack::Test::Methods

  def app
    ALLSEARCH_RACK_APP
  end
end
RSpec.configure do |config|
  config.include RackTestHelpers
end
