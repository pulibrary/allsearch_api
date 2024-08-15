# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/service_controller_shared_examples'

RSpec.describe LibguidesController do
  before do
    stub_request(:post, 'https://lgapi-us.libapps.com/1.2/oauth/token')
      .with(body: 'client_id=ABC&client_secret=12345&grant_type=client_credentials')
      .to_return(status: 200, body: file_fixture('libanswers/oauth_token.json'))
    stub_request(:get, %r{https://lgapi-us.libapps.com/1.2/guides})
      .with(headers: { 'Authorization' => 'Bearer abcdef1234567890abcdef1234567890abcdef12' })
      .to_return(status: 200, body: file_fixture('libguides/asian_american_studies.json'))
  end

  it_behaves_like 'a service controller'
end
