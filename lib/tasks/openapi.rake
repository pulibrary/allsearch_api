# frozen_string_literal: true

namespace :openapi do
  desc 'Re-generate the OpenAPI/swagger spec'
  task generate: :environment do
    system 'GENERATE_OPEN_API_SPECS=true bundle exec rspec'
  end
end
