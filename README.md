# README
API-only Rails app generated using the command:
```bash
rails new bento_rails_api --api --skip-javascript --skip-asset-pipeline --skip-spring --skip-test --no-rc --skip-active-record
```

Requires:
- Ruby 3.2

## Getting started
1. Clone the repository - `git clone git@github.com:pulibrary/bento_rails_api.git`
1. Go to the repository directory - `cd bento_rails_api`
1. Install the required gems - `bundle install`
1. Start the application server on localhost:2300 - `bundle exec rails s`
1. See the application running at http://localhost:3000/

## Run tests
### RSpec
```bash
bundle exec rspec
```

### Rubocop
```bash
bundle exec rubocop
```
## Create a new service
- Controller
  - Must have `#show` method. Can base entire controller on existing controllers, just instantiate the appropriate model within the show method
- Route
  - `  get '/search/new_service/', to: 'new_service#show', defaults: { format: 'json' }`
- Model
  - Must have methods for the `doc_keys` in the `#parsed_records` method
- Request Spec
