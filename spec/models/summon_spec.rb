# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Summon do
  let(:query_terms) { 'forest' }
  let(:summon) { described_class.new(query_terms:) }
  let(:id_string) do
    'application/xml\n' \
      'Tue, 30 Jun 2009 12:10:24 GMT\n' \
      'api.summon.serialssolutions.com\n' \
      '/2.0.0/search\n' \
      'ff=ContentType,or,1,15&q=forest\n'
  end

  before do
    travel_to(Time.gm(2009, 0o6, 30, 12, 10, 24))
  end

  it 'has access to the required variables' do
    expect(summon.access_id).to eq('princeton')
    # From ExLibris authentication example
    expect(summon.secret_key).to eq('ed2ee2e0-65c1-11de-8a39-0800200c9a66')
    expect(summon.api_host).to eq('api.summon.serialssolutions.com')
    expect(summon.api_path).to eq('/2.0.0/search')
    expect(summon.query_string_for_constructed_id).to eq('ff=ContentType,or,1,15&q=forest')
    expect(summon.summon_date).to eq('Tue, 30 Jun 2009 12:10:24 GMT')
    # Change this to 'application/json' for real implementation
    expect(summon.accept_header_value).to eq('application/xml')
  end

  it 'can construct an ID string from a request' do
    expect(summon.id_string).to eq(id_string)
  end

  it 'can compute the digest' do
    pending('Understanding how Summon calculates the digest better')
    expect(summon.digest).to eq('3a4+j0Wrrx6LF8X4iwOLDetVOu4=')
  end

  context 'with a ruby digest' do
    let(:ruby_digest) { 'vim1N5aDsYDEg4MtFw9m7lhr/J8=' }

    it 'gets the same digest with different methods' do
      expect(summon.digest).to eq(ruby_digest)
      expect(summon.digest_from_gem).to eq(ruby_digest)
    end
  end
end
