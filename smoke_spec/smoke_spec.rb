# frozen_string_literal: true

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'Deployed environment', :staging_test do
  let(:host) { 'allsearch-api-staging.princeton.edu' }
  let(:path) { nil }
  let(:query) { nil }
  let(:uri) { URI::HTTPS.build(host:, path:, query:) }
  let(:response) { JSON.parse(Net::HTTP.get(uri)) }

  around do |example|
    WebMock.allow_net_connect!
    example.run
    WebMock.disable_net_connect!
  end

  describe 'using curl' do
    # let(:response) { JSON.parse(`curl https://#{host}`) }

    it 'has the expected keys' do
      response = `curl https://#{host}`
      puts(response)
      # expect(response['error']).to be_nil
      # expect(response.keys).to include('application', 'environment', 'github_link', 'documentation')
    end
  end

  it 'does not get an error' do
    expect(response['error']).to be_nil
  end

  it 'can test against a deployed environment' do
    expect(response.keys).to include('application', 'environment', 'github_link', 'documentation')
  end

  describe 'making a request against the art museum api' do
    let(:path) { '/search/artmuseum' }
    let(:query) { 'query=potato' }

    it 'can get a response' do
      expect(response.keys).to include('number', 'records', 'more')
    end
  end

  describe 'checking the health endpoint' do
    let(:path) { '/health.json' }

    it 'has a status of ok' do
      expect(response['status']).to eq('ok')
    end
  end
end
# rubocop:enable RSpec/DescribeClass
