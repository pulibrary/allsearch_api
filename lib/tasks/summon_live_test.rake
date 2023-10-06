# frozen_string_literal: true

namespace :summon do
  desc 'Ensure that complex Summon api call is still working in development ' \
       '- be sure the API key is exported in your environment'
  task test: :environment do
    summon_api = SummonApi.new(query_terms: 'forest')
    response = summon_api.service_response
    puts response.documents.first.title
  end
end
