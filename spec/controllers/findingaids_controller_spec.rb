# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/service_controller_shared_examples'

RSpec.describe FindingaidsController do
  before do
    stub_solr(collection: 'pulfalight-production',
              query: 'facet=false&fl=id,collection_ssm,creator_ssm,level_ssm,abstract_ssm,' \
                     'repository_ssm,extent_ssm,accessrestrict_ssm,normalized_date_ssm&fq=level_ssm:collection&' \
                     'q=bad%20bin%20bash%20script&rows=3&sort=score%20desc,%20title_sort%20asc',
              fixture: 'solr/findingaids/cats.json')
    stub_solr(collection: 'pulfalight-production',
              query: 'facet=false&fl=id,collection_ssm,creator_ssm,level_ssm,abstract_ssm,' \
                     'repository_ssm,extent_ssm,accessrestrict_ssm,normalized_date_ssm&fq=level_ssm:collection&' \
                     'q=war%20and%20peace&rows=3&sort=score%20desc,%20title_sort%20asc',
              fixture: 'solr/findingaids/cats.json')
    stub_solr(collection: 'pulfalight-production',
              query: 'facet=false&fl=id,collection_ssm,creator_ssm,level_ssm,abstract_ssm,' \
                     'repository_ssm,extent_ssm,accessrestrict_ssm,normalized_date_ssm&fq=level_ssm:collection&' \
                     'q=%25&rows=3&sort=score%20desc,%20title_sort%20asc',
              fixture: 'solr/findingaids/cats.json')
    stub_solr(collection: 'pulfalight-production',
              query: 'facet=false&fl=id,collection_ssm,creator_ssm,level_ssm,abstract_ssm,' \
                     'repository_ssm,extent_ssm,accessrestrict_ssm,normalized_date_ssm&fq=level_ssm:collection&' \
                     'q=读&rows=3&sort=score%20desc,%20title_sort%20asc',
              fixture: 'solr/findingaids/cats.json')
  end

  it_behaves_like 'a service controller'
end
