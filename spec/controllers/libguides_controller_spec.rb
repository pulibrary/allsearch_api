# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/service_controller_shared_examples'

RSpec.describe LibguidesController do
  before do
    stub_libguides(query: 'bad%20bin%20bash%20script', fixture: 'libguides/asian_american_studies.json')
    stub_libguides(query: 'war and peace', fixture: 'libguides/asian_american_studies.json')
    stub_libguides(query: '%2525', fixture: 'libguides/asian_american_studies.json')
    stub_libguides(query: '读', fixture: 'libguides/asian_american_studies.json')
  end

  it_behaves_like 'a service controller'
end
