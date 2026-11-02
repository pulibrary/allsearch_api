# frozen_string_literal: true

Router = Rack::Builder.new do
  map('/') { run MainController }
  map('/banner') { run BannerController.new }
  map('/api-docs') { run SwaggerUiController }
  map('/health') { run HealthcheckController }
  map('/health.json') { run HealthcheckController }
  map('/search/article') { run SearchController.new(service_class: Article) }
  map('/search/artmuseum/') { run SearchController.new(service_class: ArtMuseum) }
  map('/search/best-bet/') { run SearchController.new(service_class: BestBet) }
  map('/search/catalog/') { run SearchController.new(service_class: Catalog) }
  map('/search/database/') { run SearchController.new(service_class: LibraryDatabase) }
  map('/search/dpul/') { run SearchController.new(service_class: Dpul) }
  map('/search/findingaids/') { run SearchController.new(service_class: Findingaids) }
  map('/search/journals/') { run SearchController.new(service_class: Journals) }
  map('/search/libanswers/') { run SearchController.new(service_class: Libanswers) }
  map('/search/libguides/') { run SearchController.new(service_class: Libguides) }
  map('/search/pulmap') { run SearchController.new(service_class: Pulmap) }
  map('/search/staff/') { run SearchController.new(service_class: LibraryStaff) }
  map('/search/website') { run SearchController.new(service_class: LibraryWebsite) }
end
