# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/service_controller_shared_examples'

RSpec.describe PulmapController do
  before do
    stub_request(:get, %r{http://lib-solr8-prod.princeton.edu:8983/solr/pulmap})
      .to_return(status: 200, body: file_fixture('solr/pulmap/scribner.json'))
  end

  it_behaves_like 'a service controller'
end
