# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount HealthMonitor::Engine, at: '/' # Can see at /health
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  match '/', to: MainController, via: :all
  match '/banner', to: BannerController, via: :all
  get '/search/article', to: ArticleController, via: :all
  get '/search/artmuseum/', to: ArtMuseumController, via: :all
  get '/search/best-bet/', to: BestBetController, via: :all
  get '/search/catalog/', to: CatalogController, via: :all
  get '/search/database/', to: LibraryDatabaseController, via: :all
  get '/search/dpul/', to: DpulController, via: :all
  get '/search/findingaids/', to: FindingaidsController, via: :all
  get '/search/journals/', to: JournalsController, via: :all
  get '/search/libanswers/', to: 'libanswers#show', defaults: { format: 'json' }
  get '/search/libguides/', to: 'libguides#show', defaults: { format: 'json' }
  get '/search/pulmap', to: PulmapController, via: :all
  get '/search/staff/', to: LibraryStaffController, via: :all
  get '/search/website', to: LibraryWebsiteController, via: :all
end
