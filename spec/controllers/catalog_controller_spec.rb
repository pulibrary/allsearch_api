# frozen_string_literal: true

require 'spec_helper'

describe CatalogController do
  it 'reports the url to honeybadger on error' do
    allow(Catalog).to receive(:new).and_raise(AllsearchError.new(msg: 'Some bad error'))
    honeybadger = class_double(Honeybadger, notify: true)

    env = { 'rack.url_scheme' => 'http', 'HTTP_HOST' => 'allsearch-api.princeton.edu',
            'SCRIPT_NAME' => '/search/catalog', 'QUERY_STRING' => 'query=my+nice+query' }
    controller = described_class.new(Rack::Request.new(env), env, honeybadger:)

    controller.response

    expect(honeybadger).to have_received(:notify).with(anything, url: 'http://allsearch-api.princeton.edu/search/catalog?query=my+nice+query')
  end
end
