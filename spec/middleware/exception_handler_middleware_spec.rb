# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ExceptionHandlerMiddleware do
  it 'returns an error' do
    app = ->(_env) { raise 'This application hit a weird error!' }
    middleware = described_class.new(app)
    expect(middleware.call({})).to eq [500, {},
                                       ['{"error": {"problem": "ERROR", "message": "We encountered an error."}}']]
  end

  it 'notifies honeybadger' do
    my_exception = StandardError.new('this is my exception!')
    app = ->(_env) { raise my_exception }
    honeybadger = class_double(Honeybadger, notify: true)
    middleware = described_class.new(app, honeybadger:)
    middleware.call({})

    expect(honeybadger).to have_received(:notify).with(my_exception, anything)
  end

  it 'includes the url' do
    my_exception = StandardError.new('this is my exception!')
    app = ->(_env) { raise my_exception }
    honeybadger = class_double(Honeybadger, notify: true)
    middleware = described_class.new(app, honeybadger:)
    middleware.call({ 'rack.url_scheme' => 'http', 'HTTP_HOST' => 'allsearch-api.princeton.edu',
                      'SCRIPT_NAME' => '/search/catalog', 'QUERY_STRING' => 'query=my+nice+query' })

    expect(honeybadger).to have_received(:notify).with(anything, url: 'http://allsearch-api.princeton.edu/search/catalog?query=my+nice+query')
  end
end
