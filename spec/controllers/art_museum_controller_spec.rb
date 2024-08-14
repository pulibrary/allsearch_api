# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/service_controller_shared_examples'

RSpec.describe ArtMuseumController do
  before do
    stub_art_museum(query: 'bad bin bash script', fixture: 'art_museum/cats.json')
    stub_art_museum(query: 'war and peace', fixture: 'art_museum/cats.json')
    stub_art_museum(query: '读', fixture: 'art_museum/cats.json')
    stub_art_museum(query: '%25', fixture: 'art_museum/cats.json')
  end

  it_behaves_like 'a service controller'
end
