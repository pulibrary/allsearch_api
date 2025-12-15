# frozen_string_literal: true
require_relative '../../init/rom_factory'
namespace :best_bets do
  desc 'Refresh the best_bet_documents table with data from the spreadsheet'
  task sync: :autoload do
    BestBetLoadingService.new.run
  end
end
