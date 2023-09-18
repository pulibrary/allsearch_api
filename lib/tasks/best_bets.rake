# frozen_string_literal: true

namespace :best_bets do
  desc 'Refresh the best_bet_documents table with data from the spreadsheet'
  task sync: :environment do
    BestBetLoadingService.new.run
  end
end
