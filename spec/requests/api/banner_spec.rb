# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'banner' do
  path '/banner' do
    get('show banner') do
      tags 'Banner'
      operationId 'displayBanner'
      produces 'application/json'
      description 'Displays the current settings for the banner'
      response(200, 'successful') do
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end
    end
  end
end
