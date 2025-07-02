# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount HealthMonitor::Engine, at: '/' # Can see at /health
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  match '/', to: MainController, via: :all
  match '/banner', to: BannerController, via: :all
  get '/search/article', to: 'article#show', defaults: { format: 'json' }
  get '/search/artmuseum/', to: 'art_museum#show', defaults: { format: 'json' }
  get '/search/best-bet/', to: 'best_bet#show', defaults: { format: 'json' }
  get '/search/catalog/', to: 'catalog#show', defaults: { format: 'json' }
  get '/search/database/', to: 'library_database#show', defaults: { format: 'json' }
  get '/search/dpul/', to: DpulController, via: :all
  get '/search/findingaids/', to: 'findingaids#show', defaults: { format: 'json' }
  get '/search/journals/', to: 'journals#show', defaults: { format: 'json' }
  get '/search/libanswers/', to: 'libanswers#show', defaults: { format: 'json' }
  get '/search/libguides/', to: 'libguides#show', defaults: { format: 'json' }
  get '/search/pulmap', to: 'pulmap#show', defaults: { format: 'json' }
  get '/search/staff/', to: 'library_staff#show', defaults: { format: 'json' }
  get '/search/website', to: 'library_website#show', defaults: { format: 'json' }
end
