# frozen_string_literal: true

require 'forwardable'

# This class is responsible for caching Oauth Tokens
# in the db so that we don't have to spend extra
# network requests fetching new tokens
class OAuthTokenCache
  include Dry::Monads[:maybe]
  extend Forwardable

  def initialize(service:, endpoint:)
    @service = service
    @endpoint = endpoint
  end

  def token
    find_existing_entry
      .or { create_new_entry }
      .fmap { it[:token] }
      .value_or(nil)
  end

  private

  attr_reader :service, :endpoint

  def_delegators :oauth_service, :new_token, :expiration_time

  def find_existing_entry
    repo.find(service:, endpoint:)
        .bind do |existing_entry|
          existing_entry_expiration_time = existing_entry[:expiration_time]
          if existing_entry_expiration_time && Time.now.utc < existing_entry_expiration_time
            Some(existing_entry)
          else
            update_existing_entry(existing_entry[:id])
          end
        end
  end

  def update_existing_entry(id)
    Some(repo.update(id,
                     { token: new_token, expiration_time: expiration_time }))
  end

  def create_new_entry
    Some(repo.create(service:, endpoint:, token: new_token,
                     expiration_time: expiration_time))
  end

  def repo
    @repo ||= RepositoryFactory.oauth_token
  end

  def oauth_service
    @oauth_service ||= OAuthService.new(service:, endpoint:)
  end
end
