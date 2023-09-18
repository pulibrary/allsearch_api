# frozen_string_literal: true

class CreateBestBetDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :best_bet_documents do |t|
      t.string :title
      t.string :description
      t.string :url
      t.string :search_terms, array: true
      t.date :last_update

      t.timestamps
    end
  end
end
