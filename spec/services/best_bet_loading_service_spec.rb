# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BestBetLoadingService, :truncate do
  let(:google_response) { file_fixture('google_sheets/best_bets.csv') }
  let(:title) { 'Some title' }
  let(:search_terms) { '{some, terms}' }
  let(:url) { 'https://example.com' }

  let(:rom) { Rails.application.config.rom }
  let(:repo) { RepositoryFactory.best_bet }
  let(:best_bet) { rom.relations[:best_bet_records] }

  before do
    stub_request(:get, 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSSDYbAmj_SDVK96DJItSsir_PbjMIqe8cBMvBfRIh4fpVzv3aozhCdulrgJXZzwl-fh-lbULMuLZuO/pub?gid=170493948&single=true&output=csv')
      .to_return(status: 200, body: google_response)
  end

  it 'creates a new row in the best_bet table for each CSV row' do
    expect { described_class.new.run }.to change{ best_bet.count }.by(7)
    third_record = best_bet.to_a[2]
    expect(third_record.title).to eq('Access and Borrowing')
    expect(third_record.description).to eq('Information on access and borrowing privileges ' \
                                           'for different categories of library patrons, espec')
    expect(third_record.url).to eq('https://library.princeton.edu/services/access')
    expect(third_record.search_terms).to contain_exactly('access', 'access office', 'privileges',
                                                        'privileges office', 'visitors')
    expect(third_record.last_update).to eq(Date.new(2021, 7, 8))
  end

  it 'is idempotent' do
    described_class.new.run
    expect { described_class.new.run }.not_to change{ best_bet.count }
  end

  context 'when file does not have the required headers' do
    let(:google_response) { 'bad response' }

    it 'does not proceed' do
      logger = instance_double(SemanticLogger::Logger, error: true)
      repo.create(title:, url: 'library.princeton.edu', search_terms:)
      expect { described_class.new.run }.not_to(change { best_bet.count })
      expect(logger).to have_received(:error)
        .with('The BestBetLoadingService did not load the CSV ' \
              "because the headers didn't match. The expected headers are: " \
              'Title, Description, URL, Search Terms, Last Update, and Updated By. ' \
              'The new CSV headers are bad response.')
    end
  end

  context 'when a best bet in postgres is no longer in the CSV' do
    it 'removes it from the database' do
      repo = RepositoryFactory.best_bet
      old_record = repo.create(id: 123, title:, search_terms:, url:)
      expect(best_bet.where(id: 123)).to contain_exactly(old_record)
      described_class.new.run
      expect(best_bet.where(id: 123).count).to eq 0
    end
  end

  context 'when a best bet has updated info in the CSV' do
    it 'updates the relevant fields' do
      repo.create(title: 'Access and Borrowing', url: 'incorrect.com', search_terms:)
      expect(best_bet.where(title: 'Access and Borrowing').first.url).to eq 'incorrect.com'
      described_class.new.run
      expect(best_bet.where(title: 'Access and Borrowing').first.url).to eq 'https://library.princeton.edu/services/access'
    end
  end

  context 'when the CSV is suspiciously small relative to the number of database rows' do
    it 'does not proceed' do
      30.times { repo.create(title:, url:, search_terms:) }
      expect { described_class.new.run }.not_to(change { best_bet.count })
    end

    it 'logs an error' do
      logger = instance_double(SemanticLogger::Logger, error: true)
      30.times { repo.create(title:, url:, search_terms:) }
      expect { described_class.new.run }.not_to(change { best_bet.count })
      expect(logger).to have_received(:error)
        .once.with('The BestBetLoadingService had a much shorter CSV. ' \
                   'The original length was 30 rows, the new length is 8 rows.')
    end
  end
end
