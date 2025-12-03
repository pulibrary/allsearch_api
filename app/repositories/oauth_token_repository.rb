# frozen_string_literal: true

class OAuthTokenRepository < ROM::Repository[:oauth_tokens]
  include Dry::Monads[:maybe]

  commands :create,
           use: :timestamps,
           plugins_options: { timestamps: { timestamps: [:created_at, :updated_at] } }

  commands update: :by_pk,
           use: :timestamps,
           plugins_options: { timestamps: { timestamps: [:updated_at] } }

  def find(service:, endpoint:)
    results = oauth_tokens.where(service:, endpoint:).to_a
    if results.one?
      Some(results.first)
    else
      None()
    end
  end
end
