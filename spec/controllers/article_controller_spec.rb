# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/service_controller_shared_examples'

RSpec.describe ArticleController do
  before do
    stub_request(:get, %r{http://api.summon.serialssolutions.com/2.0.0/search})
      .to_return(status: 200,
                 body: file_fixture('article/potato.json'),
                 headers: { 'Content-Type': 'application/json' })
  end

  it_behaves_like 'a service controller'
end
