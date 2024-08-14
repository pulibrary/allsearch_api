# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/service_controller_shared_examples'

RSpec.describe ArticleController do
  before do
    stub_summon(query: 'bad%20bin%20bash%20script', fixture: 'article/bash.json')
    stub_summon(query: 'war%20and%20peace', fixture: 'article/war_and_peace.json')
    stub_summon(query: '读', fixture: 'article/potato.json')
    # The search is for the string '%25' but the Summon gem turns this into %2525
    stub_summon(query: '%2525', fixture: 'article/potato.json')
  end

  it_behaves_like 'a service controller'
end
