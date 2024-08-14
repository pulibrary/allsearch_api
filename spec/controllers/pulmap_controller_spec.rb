# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/service_controller_shared_examples'

RSpec.describe PulmapController do
  before do
    stub_solr(collection: 'pulmap',
              query: 'facet=false&fl=layer_slug_s,dc_title_s,dc_creator_sm,dc_publisher_s,' \
                     'dc_format_s,dc_description_s,dc_rights_s,layer_geom_type_s&' \
                     'q=bad%20bin%20bash%20script&rows=3&sort=score%20desc',
              fixture: 'solr/pulmap/scribner.json')
    stub_solr(collection: 'pulmap',
              query: 'facet=false&fl=layer_slug_s,dc_title_s,dc_creator_sm,dc_publisher_s,' \
                     'dc_format_s,dc_description_s,dc_rights_s,layer_geom_type_s&' \
                     'q=war%20and%20peace&rows=3&sort=score%20desc',
              fixture: 'solr/pulmap/scribner.json')
    stub_solr(collection: 'pulmap',
              query: 'facet=false&fl=layer_slug_s,dc_title_s,dc_creator_sm,dc_publisher_s,' \
                     'dc_format_s,dc_description_s,dc_rights_s,layer_geom_type_s&' \
                     'q=%25&rows=3&sort=score%20desc',
              fixture: 'solr/pulmap/scribner.json')
    stub_solr(collection: 'pulmap',
              query: 'facet=false&fl=layer_slug_s,dc_title_s,dc_creator_sm,dc_publisher_s,' \
                     'dc_format_s,dc_description_s,dc_rights_s,layer_geom_type_s&' \
                     'q=读&rows=3&sort=score%20desc',
              fixture: 'solr/pulmap/scribner.json')
  end

  it_behaves_like 'a service controller'
end
