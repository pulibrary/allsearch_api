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

    expect(honeybadger).to have_received(:notify).with(my_exception)
  end
end
