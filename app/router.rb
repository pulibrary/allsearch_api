# frozen_string_literal: true

Router = Rack::Builder.new do
  map('/') { run MainController }
  map('/banner') { run BannerController.new }
  map('/api-docs') { run SwaggerUiController }
  map('/health') { run HealthcheckController }
  map('/health.json') { run HealthcheckController }
  map('/search/article') { run SearchController.new(service: Article) }
  map('/search/artmuseum/') { run SearchController.new(service: ArtMuseum) }
  map('/search/best-bet/') { run SearchController.new(service: BestBet) }
  map('/search/catalog/') { run SearchController.new(service: Catalog) }
  map('/search/database/') { run SearchController.new(service: LibraryDatabase) }
  map('/search/dpul/') { run SearchController.new(service: Dpul) }
  map('/search/findingaids/') { run SearchController.new(service: Findingaids) }
  map('/search/journals/') { run SearchController.new(service: Journals) }
  map('/search/libanswers/') { run SearchController.new(service: Libanswers) }
  map('/search/libguides/') { run SearchController.new(service: Libguides) }
  map('/search/pulmap') { run SearchController.new(service: Pulmap) }
  map('/search/staff/') { run SearchController.new(service: LibraryStaff) }
  map('/search/website') { run SearchController.new(service: LibraryWebsite) }
end
