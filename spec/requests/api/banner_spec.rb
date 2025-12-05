# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'banner' do
  openapi_path '/banner' do
    openapi_get({
                  'summary' => '/banner',
                  'tags' => ['Banner'],
                  'operationId' => 'displayBanner',
                  'description' => 'Displays the current settings for the banner'
                }) do
      openapi_response('200', 'successful')
    end
  end
end
