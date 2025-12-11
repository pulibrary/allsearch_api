# frozen_string_literal: true

namespace :summon do
  desc 'Ensure that complex Summon api call is still working in development ' \
       '- be sure the API key is exported in your environment'
  task test: :autoload do
    summon_api = Article.new(query_terms: 'forest')
    response = summon_api.service_response

    puts "Number of responses: #{response.record_count}"
    puts "Query string: #{response.query.query_string}"
    puts "First title: #{response.documents.first.title}"
  end
end
