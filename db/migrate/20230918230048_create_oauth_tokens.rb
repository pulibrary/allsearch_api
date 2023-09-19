# frozen_string_literal: true

class CreateOAuthTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :oauth_tokens do |t|
      t.string :service, null: false
      t.string :endpoint, null: false
      t.string :token, null: false
      t.datetime :expiration_time, null: false

      t.timestamps
    end

    add_index :oauth_tokens, :service, unique: true
    add_index :oauth_tokens, :endpoint, unique: true
  end
end
