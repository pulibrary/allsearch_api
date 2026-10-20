# frozen_string_literal: true

require 'spec_helper'

describe SearchController do
  it 'reports the url to honeybadger on error' do
    my_erroring_service = Class.new do
      def initialize = raise AllsearchError.new(msg: 'Some bad error')
    end
    honeybadger = class_double(Honeybadger, notify: true)

    env = { 'rack.url_scheme' => 'http', 'HTTP_HOST' => 'allsearch-api.princeton.edu',
            'SCRIPT_NAME' => '/search/catalog', 'QUERY_STRING' => 'query=my+nice+query' }
    controller = described_class.new(service: my_erroring_service, honeybadger:)

    controller.call(env)

    expect(honeybadger).to have_received(:notify).with(anything, url: 'http://allsearch-api.princeton.edu/search/catalog?query=my+nice+query')
  end
end
