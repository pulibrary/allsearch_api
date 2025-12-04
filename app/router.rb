# frozen_string_literal: true

Router = Rack::Builder.new do
  map('/') { run MainController }
  map('/banner') { run BannerController }
  map('/api-docs') { run SwaggerUiController }
  map('/api-docs/v1/swagger.yaml') { run OpenApiSpecController }
  map('/health') { run HealthcheckController }
  map('/health.json') { run HealthcheckController }
  map('/search/article') { run ArticleController }
  map('/search/artmuseum/') { run ArtMuseumController }
  map('/search/best-bet/') { run BestBetController }
  map('/search/catalog/') { run CatalogController }
  map('/search/database/') { run LibraryDatabaseController }
  map('/search/dpul/') { run DpulController }
  map('/search/findingaids/') { run FindingaidsController }
  map('/search/journals/') { run JournalsController }
  map('/search/libanswers/') { run LibanswersController }
  map('/search/libguides/') { run LibguidesController }
  map('/search/pulmap') { run PulmapController }
  map('/search/staff/') { run LibraryStaffController }
  map('/search/website') { run LibraryWebsiteController }
end
