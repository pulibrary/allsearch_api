# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /banner' do
  before do
    get '/banner'
  end

  it 'returns json' do
    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end

  it 'has the expected keys' do
    expect(response.parsed_body.keys).to contain_exactly('text', 'display_banner', 'alert_status',
                                                         'dismissable', 'autoclear')
  end

  it 'has the expected default values' do
    expect(response.parsed_body.values).to contain_exactly('', false, 'info', true, false)
  end

  context 'with an updated banner' do
    let(:banner) { Banner.first }
    let(:text_html) do
      '<h2>This is a big heading about an important thing</h2><p>It includes a <a href="https://www.example.com">link</a></p>'
    end

    it 'can pass on encoded html' do
      banner.text = text_html
      banner.save!
      get '/banner'
      # includes escaped html to pass on, which will be decoded on the other side
      expect(response.body).to match(/u003ch2/)
      expect(response.parsed_body[:text]).to eq(text_html)
    end
  end
end
