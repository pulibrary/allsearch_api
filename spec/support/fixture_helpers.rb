# frozen_string_literal: true

module FixtureHelpers
  def stub_art_museum(query:, fixture:)
    stub_request(:get, "https://data.artmuseum.princeton.edu/search?q=#{query}&size=3&type=all")
      .to_return(status: 200, body: file_fixture(fixture))
  end

  def stub_solr(collection:, query:, fixture:)
    stub_request(:get, "http://lib-solr8-prod.princeton.edu:8983/solr/#{collection}/select?#{query}")
      .to_return(status: 200, body: file_fixture(fixture))
  end

  def stub_libanswers(query:, fixture:)
    stub_request(:post, 'https://faq.library.princeton.edu/api/1.1/oauth/token')
      .with(body: 'client_id=ABC&client_secret=12345&grant_type=client_credentials')
      .to_return(status: 200, body: file_fixture('libanswers/oauth_token.json'))
    stub_request(:get, "https://faq.library.princeton.edu/api/1.1/search/#{query}?iid=344&limit=3")
      .with(
        headers: {
          'Authorization' => 'Bearer abcdef1234567890abcdef1234567890abcdef12'
        }
      )
      .to_return(status: 200, body: file_fixture(fixture))
  end

  def stub_libguides(query:, fixture:)
    stub_request(:post, 'https://lgapi-us.libapps.com/1.2/oauth/token')
      .with(body: 'client_id=ABC&client_secret=12345&grant_type=client_credentials')
      .to_return(status: 200, body: file_fixture('libanswers/oauth_token.json'))
    stub_request(:get, "https://lgapi-us.libapps.com/1.2/guides?expand=owner,subjects,tags&search_terms=#{query}&sort_by=relevance&status=1")
      .with(
        headers: {
          'Authorization' => 'Bearer abcdef1234567890abcdef1234567890abcdef12'
        }
      )
      .to_return(status: 200, body: file_fixture(fixture))
  end

  def stub_summon(query:, fixture:)
    q_string = "http://api.summon.serialssolutions.com/2.0.0/search?s.dym=t&s.fvf=ContentType,Newspaper%20Article,true&s.ho=t&s.ps=3&s.q=#{query}"
    stub_request(:get, q_string)
      .to_return(status: 200,
                 body: file_fixture(fixture),
                 headers: { 'Content-Type': 'application/json' })
  end

  def stub_website(query:, fixture:)
    url = URI::HTTPS.build(host: LibraryWebsite.library_website_host, path: '/ps-library/search/results')
    stub_request(:post, url)
      .with(body: { 'search' => query })
      .to_return(status: 200,
                 body: file_fixture(fixture),
                 headers: { 'Content-Type': 'application/json' })
  end
end
