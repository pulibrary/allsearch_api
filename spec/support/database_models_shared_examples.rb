# frozen_string_literal: true

RSpec.shared_examples 'a database service' do
  it 'has a searchable field' do
    expect(described_class.column_names).to include('searchable')
  end

  it 'has a tsvector field' do
    column_hash = described_class.columns_hash['searchable']
    expect(column_hash.sql_type).to eq('tsvector')
  end

  it 'has a query method' do
    expect(described_class.methods - ApplicationRecord.methods).to include(:query)
  end

  it 'can find the record with an unaccented query term' do
    expect(described_class.query(unaccented).pluck(:id)).to contain_exactly(database_record.id)
  end

  it 'can find the record with a precomposed query term' do
    expect(described_class.query(precomposed).pluck(:id)).to contain_exactly(database_record.id)
  end

  it 'can find the record with a decomposed query term' do
    expect(described_class.query(decomposed).pluck(:id)).to contain_exactly(database_record.id)
  end
end
