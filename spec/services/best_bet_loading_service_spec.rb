# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BestBetLoadingService do
  let(:google_response) { file_fixture('google_sheets/best_bets.csv') }
  let(:title) { 'Some title' }
  let(:search_terms) { 'some, terms' }
  let(:url) { 'https://example.com' }

  before do
    stub_request(:get, 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSSDYbAmj_SDVK96DJItSsir_PbjMIqe8cBMvBfRIh4fpVzv3aozhCdulrgJXZzwl-fh-lbULMuLZuO/pub?gid=170493948&single=true&output=csv')
      .to_return(status: 200, body: google_response)
  end

  it 'creates a new row in the best_bet table for each CSV row' do
    expect { described_class.new.run }.to change(BestBetRecord, :count).by(6)
    expect(BestBetRecord.third.title).to eq('Access and Borrowing')
    expect(BestBetRecord.third.description).to eq('Information on access and borrowing privileges ' \
                                                  'for different categories of library patrons, espec')
    expect(BestBetRecord.third.url).to eq('https://library.princeton.edu/services/access')
    expect(BestBetRecord.third.search_terms).to contain_exactly('access', 'access office', 'privileges',
                                                                'privileges office', 'visitors')
    expect(BestBetRecord.third.last_update).to eq(Date.new(2021, 7, 8))
  end

  it 'is idempotent' do
    described_class.new.run
    expect { described_class.new.run }.not_to change(BestBetRecord, :count)
  end

  context 'when file does not have the required headers' do
    let(:google_response) { 'bad response' }

    it 'does not proceed' do
      allow(Rails.logger).to receive(:error)
      BestBetRecord.create!(title:, url: 'library.princeton.edu', search_terms:)
      expect { described_class.new.run }.not_to(change(BestBetRecord, :count))
      expect(Rails.logger).to have_received(:error)
        .with('The BestBetLoadingService did not load the CSV ' \
              "because the headers didn't match. The expected headers are: " \
              'Title, Description, URL, Search Terms, Last Update, and Updated By. ' \
              'The new CSV headers are .')
    end
  end

  context 'when a best bet in postgres is no longer in the CSV' do
    it 'removes it from the database' do
      old_record = BestBetRecord.create!(id: 123, title:, search_terms:, url:)
      expect(BestBetRecord.where(id: 123)).to contain_exactly(old_record)
      described_class.new.run
      expect(BestBetRecord.where(id: 123)).to be_empty
    end
  end

  context 'when a best bet has updated info in the CSV' do
    it 'updates the relevant fields' do
      BestBetRecord.create!(title: 'Access and Borrowing', url: 'incorrect.com', search_terms:)
      expect(BestBetRecord.find_by(title: 'Access and Borrowing').url).to eq 'incorrect.com'
      described_class.new.run
      expect(BestBetRecord.find_by(title: 'Access and Borrowing').url).to eq 'https://library.princeton.edu/services/access'
    end
  end

  context 'when the CSV is suspiciously small relative to the number of database rows' do
    it 'does not proceed' do
      30.times { BestBetRecord.create!(title:, url:, search_terms:) }
      expect { described_class.new.run }.not_to(change(BestBetRecord, :count))
    end

    it 'logs an error' do
      allow(Rails.logger).to receive(:error)
      30.times { BestBetRecord.create!(title:, url:, search_terms:) }
      expect { described_class.new.run }.not_to(change(BestBetRecord, :count))
      expect(Rails.logger).to have_received(:error)
        .once.with('The BestBetLoadingService had a much shorter CSV. ' \
                   'The original length was 30 rows, the new length is 7 rows.')
    end
  end
end
