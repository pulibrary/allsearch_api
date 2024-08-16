# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/service_controller_shared_examples'

RSpec.describe ArtMuseumController do
  before do
    stub_request(:get, %r{https://data.artmuseum.princeton.edu/search})
      .to_return(status: 200, body: file_fixture('art_museum/cats.json'))
  end

  it_behaves_like 'a service controller'
end
