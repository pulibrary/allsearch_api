# frozen_string_literal: true

RSpec.shared_examples 'a solr search controller' do
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

    it_behaves_like 'a search controller'

    it 'sanitizes input' do
      get "/search/#{service_path}?query=#{CGI.escape bad_script}"
      expect(WebMock).to have_requested(:get, /bad%20bin%20bash%20script/)
    end

    it 'removes redundant space from query' do
      get "/search/#{service_path}?query=#{CGI.escape redundant_spaces}"
      expect(WebMock).to have_requested(:get, /war%20and%20peace/)
    end

    it 'does not throw an error when the url contains numbers and the percent sign' do
      get "/search/#{service_path}?query=#{CGI.escape percent_sign}"
      expect(WebMock).to have_requested(:get, /%25/)
    end
  end
end

RSpec.shared_examples 'a search controller' do
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

    it 'responds 200 OK for a script injection attempt' do
      get "/search/#{service_path}?query=#{CGI.escape bad_script}"
      expect(last_response).to be_successful
    end

    it 'responds 200 OK for a redundant space query' do
      get "/search/#{service_path}?query=#{CGI.escape redundant_spaces}"
      expect(last_response).to be_successful
    end

    it 'responds 200 OK when the url contains numbers and the percent sign' do
      get "/search/#{service_path}?query=#{CGI.escape percent_sign}"
      expect(last_response).to be_successful
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
