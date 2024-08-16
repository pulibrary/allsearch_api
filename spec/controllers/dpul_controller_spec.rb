# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/service_controller_shared_examples'

RSpec.describe DpulController do
  before do
    stub_request(:get, %r{http://lib-solr8-prod.princeton.edu:8983/solr/dpul-production})
      .to_return(status: 200, body: file_fixture('solr/dpul/cats.json'))
  end

  it_behaves_like 'a service controller'
end
