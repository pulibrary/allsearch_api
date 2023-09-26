# frozen_string_literal: true

# This class is responsible for displaying basic information at the root of the app
class Main
  MAIN_INFO = {
    application: 'Princeton University Library All Search API',
    environment: Rails.env,
    github_link: 'https://github.com/pulibrary/allsearch_api',
    documentation: 'https://allsearch-api.princeton.edu/api-docs'
  }.freeze

  def self.info
    MAIN_INFO
  end
end
