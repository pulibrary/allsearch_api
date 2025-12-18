# frozen_string_literal: true

class RenameBestBestDocumentsToBestBetRecords < ActiveRecord::Migration[7.0]
  def change
    rename_table :best_bet_documents, :best_bet_records
  end
end
