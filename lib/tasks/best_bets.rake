# frozen_string_literal: true

require_relative '../../init/rom_factory'
namespace :best_bets do
  desc 'Refresh the best_bet_documents table with data from the spreadsheet'
  task sync: [:autoload, :database_connection] do
    BestBetLoadingService.new(rom_container: ALLSEARCH_ROM).run
  end
end
