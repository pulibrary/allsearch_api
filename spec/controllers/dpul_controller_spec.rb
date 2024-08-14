# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/service_controller_shared_examples'

RSpec.describe DpulController do
  before do
    stub_solr(collection: 'dpul-production',
              query: 'facet=false&fl=id,readonly_title_ssim,readonly_creator_ssim,readonly_publisher_ssim,' \
                     'readonly_format_ssim,readonly_collections_tesim&' \
                     'group=true&group.facet=true&group.field=content_metadata_iiif_manifest_field_ssi&group.limit=1&' \
                     'group.main=true&q=bad%20bin%20bash%20script&rows=3&sort=score%20desc',
              fixture: 'solr/dpul/cats.json')
    stub_solr(collection: 'dpul-production',
              query: 'facet=false&fl=id,readonly_title_ssim,readonly_creator_ssim,readonly_publisher_ssim,' \
                     'readonly_format_ssim,readonly_collections_tesim&' \
                     'group=true&group.facet=true&group.field=content_metadata_iiif_manifest_field_ssi&group.limit=1&' \
                     'group.main=true&q=war+and+peace&rows=3&sort=score%20desc',
              fixture: 'solr/dpul/cats.json')
    stub_solr(collection: 'dpul-production',
              query: 'facet=false&fl=id,readonly_title_ssim,readonly_creator_ssim,readonly_publisher_ssim,' \
                     'readonly_format_ssim,readonly_collections_tesim&' \
                     'group=true&group.facet=true&group.field=content_metadata_iiif_manifest_field_ssi&group.limit=1&' \
                     'group.main=true&q=读&rows=3&sort=score%20desc',
              fixture: 'solr/dpul/cats.json')
    stub_solr(collection: 'dpul-production',
              query: 'facet=false&fl=id,readonly_title_ssim,readonly_creator_ssim,readonly_publisher_ssim,' \
                     'readonly_format_ssim,readonly_collections_tesim&' \
                     'group=true&group.facet=true&group.field=content_metadata_iiif_manifest_field_ssi&group.limit=1&' \
                     'group.main=true&q=%25&rows=3&sort=score%20desc',
              fixture: 'solr/dpul/cats.json')
  end

  it_behaves_like 'a service controller'
end
