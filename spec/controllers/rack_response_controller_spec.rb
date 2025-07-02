# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RackResponseController do
  it 'must be subclassed' do
    request = Rack::Request.new(Rack::MockRequest.env_for('https://allsearch-api.princeton.edu/',
                                                          params: { query: 'crocodiles' }))
    expect do
      described_class.new(request).response
    end.to raise_exception(/Subclass should implement/)
  end
end
