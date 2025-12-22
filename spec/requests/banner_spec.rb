# frozen_string_literal: true

require 'rack_helper'

RSpec.describe 'GET /banner' do
  before do
    Flipper.enable(:banner)
  end

  it 'returns json' do
    get '/banner'
    expect(last_response).to be_successful
    expect(last_response.content_type).to eq('application/json; charset=utf-8')
  end

  it 'has the expected keys' do
    get '/banner'
    expect(JSON.parse(last_response.body).keys).to contain_exactly('text', 'display_banner', 'alert_status',
                                                                   'dismissible', 'autoclear')
  end

  it 'has the expected default values' do
    get '/banner'
    expect(JSON.parse(last_response.body).values).to contain_exactly('', true, 'info', true, false)
  end

  context 'with an updated banner' do
    let(:banner) { RepositoryFactory.banner.banners.first }
    let(:text_html) do
      '<h2>This is a big heading about an important thing</h2><p>It includes a <a href="https://www.example.com">link</a></p>'
    end

    it 'can pass on encoded html' do
      RepositoryFactory.banner.update banner.id, text: text_html
      get '/banner'
      expect(JSON.parse(last_response.body, symbolize_names: true)[:text]).to eq(text_html)
    end
  end

  context 'with a flipper set to on' do
    it 'is reflected in the response' do
      get '/banner'
      expect(JSON.parse(last_response.body, symbolize_names: true)[:display_banner]).to be(true)
    end
  end

  context 'with a flipper set to off' do
    before do
      Flipper.disable(:banner)
    end

    it 'is reflected in the response' do
      get '/banner'
      expect(JSON.parse(last_response.body, symbolize_names: true)[:display_banner]).to be(false)
    end
  end
end
