# frozen_string_literal: true

require_relative '../environment'

# This class is responsible for communicating with an
# OAuth server to get new access tokens
class OAuthService
  def initialize(endpoint:, service:)
    @endpoint = URI(endpoint)
    @service = service.to_sym
  end

  def new_token
    token = JSON.parse(response.body)['access_token']
    unless token
      raise AllsearchError.new(problem: 'UPSTREAM_ERROR',
                               msg: 'Could not generate a valid authentication token with upstream service.')
    end
    token
  end

  def expiration_time
    validity_in_seconds = JSON.parse(response.body)['expires_in']
    Time.now.utc + validity_in_seconds - padding_in_seconds
  end

  private

  attr_reader :endpoint, :service

  def client_id
    configuration[:client_id]
  end

  def client_secret
    configuration[:client_secret]
  end

  def response
    @response ||= Net::HTTP.post_form(endpoint, client_id:, client_secret:, grant_type:)
  end

  def grant_type
    'client_credentials'
  end

  def configuration
    @configuration ||= Environment.new.config(:allsearch)[service.to_sym]
  end

  # :reek:UtilityFunction
  def padding_in_seconds
    # 1 hour
    60 * 60
  end
end
