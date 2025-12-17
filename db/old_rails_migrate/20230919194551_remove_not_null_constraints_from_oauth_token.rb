# frozen_string_literal: true

class RemoveNotNullConstraintsFromOAuthToken < ActiveRecord::Migration[7.0]
  def up
    change_column_null :oauth_tokens, :token, true
    change_column_null :oauth_tokens, :expiration_time, true
  end

  def down
    change_column_null :oauth_tokens, :token, false
    change_column_null :oauth_tokens, :expiration_time, false
  end
end
