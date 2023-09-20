# README
API-only Rails app generated using the command:
```bash
rails new allsearch_api --api --skip-javascript --skip-asset-pipeline --skip-spring --skip-test --no-rc --skip-active-record
```

Requires:
- Ruby 3.2

## Getting started
1. Clone the repository - `git clone git@github.com:pulibrary/allsearch_api.git`
1. Go to the repository directory - `cd allsearch_api`
1. Install the required gems - `bundle install`
1. Start local solr and postgres - `bundle exec rake servers:start`
1. Start the application server on localhost:3000 - `bundle exec rails s`
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

### Reek
```bash
bundle exec reek
```

## Semgrep
This repository uses [semgrep](https://semgrep.dev/) to:

* Perform static security analysis

To run semgrep locally:

```
brew install semgrep
semgrep --config auto . # run rules from the semgrep community
```

## Create a new service
- Controller
  - Must have `#show` method. Can base entire controller on existing controllers, just instantiate the appropriate model within the show method
- Route
  - `  get '/search/new_service/', to: 'new_service#show', defaults: { format: 'json' }`
- Model
  - Must have methods for the `doc_keys` in the `#parsed_records` method
- Request Spec
