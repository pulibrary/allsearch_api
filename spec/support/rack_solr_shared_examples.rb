# frozen_string_literal: true

RSpec.shared_examples 'a rack solr controller' do
  context 'with unexpected characters' do
    let(:bad_script) { '{bad#!/bin/bash<script>}' }
    let(:simplified_chinese_cat) { '读' }
    let(:redundant_spaces) { "war   and\tpeace" }
    let(:percent_sign) { '%25' }
    let(:query_terms) do
      [
        bad_script,
        simplified_chinese_cat,
        redundant_spaces,
        percent_sign
      ]
    end

    before do
      stub_request(:get, solr_base_url)
        .to_return(status: 200, body: file_fixture('solr/dpul/cats.json'))
    end

    it 'sanitizes input' do
      get "/search/#{service_path}?query=#{CGI.escape bad_script}"

      expect(response).to have_http_status(:ok)
      expect(WebMock).to have_requested(:get, /bad%20bin%20bash%20script/)
    end

    it 'removes redundant space from query' do
      get "/search/#{service_path}?query=#{CGI.escape redundant_spaces}"

      expect(response).to have_http_status(:ok)
      expect(WebMock).to have_requested(:get, /war%20and%20peace/)
    end

    it 'does not throw an error when the url contains numbers and the percent sign' do
      get "/search/#{service_path}?query=#{CGI.escape percent_sign}"

      expect(response).to have_http_status(:ok)
      expect(WebMock).to have_requested(:get, /%25/)
    end

    it 'does not raise an error' do
      expect do
        query_terms.each do |term|
          get "/search/#{service_path}?query=#{CGI.escape term}"
        end
      end.not_to raise_exception
    end
  end

  context 'with Japanese text using differently composed characters' do
    let(:precomposed) { 'Kōbunsō Taika Koshomoku' }
    let(:no_accents) { 'Kobunso Taika Koshomoku' }
    let(:decomposed) { 'Kōbunsō Taika Koshomoku' }
    let(:query_terms) do
      [
        precomposed,
        no_accents,
        decomposed
      ]
    end

    it 'does not raise an error' do
      expect do
        query_terms.each do |term|
          get "/search/#{service_path}?query=#{CGI.escape term}"
        end
      end.not_to raise_exception
    end
  end
end
