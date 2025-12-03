# frozen_string_literal: true

# This relation provides an API for reading data
# about existing Oauth Tokens from the database
class OAuthTokenRelation < ROM::Relation[:sql]
  schema :oauth_tokens, infer: true
end
