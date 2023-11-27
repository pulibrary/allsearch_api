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

1. If the upstream service requires a secret, add it to the
[vault and environment variables](https://github.com/pulibrary/princeton_ansible/tree/main/group_vars/allsearch_api) using a princeton_ansible pull request
1. Create a new request spec for your service, based on the other service request specs
1. Create a new route in `config/routes`
    ```
    get '/search/new_service/', to: 'new_service#show', defaults: { format: 'json' }
    ```
1. Create a new controller for your service.  You can inherit from `ServiceController` and/or implement your own `#show` method.
1. Create a controller spec to confirm that query inputs are sanitized appropriately.
1. Create a model to represent a request to the upstream service.  Include the `Parsed` module in your model.
1. Create a model to represent a document returned by the upstream service. This should inherit from `Document` and implement a `#doc_keys` method.
    * `#doc_keys` should return a list of fields (as symbols) that will be
    presented in allsearch's API response.  Each symbol should match the
    name of a method in this model.
1. Create an API spec for your service in spec/requests/api/
1. Generate the swagger docs as described below.

## API documentation
Documentation lives in `https://allsearch-api.princeton.edu/api-docs`

To update the api documentation for a service:
* create a spec in: `spec/requests/api/`
   * `./bin/rails generate rspec:swagger CatalogController --spec_path requests/api/`
   *  Do the necessary changes to create the swagger doc based on the spec.
* Generate the docs by running:
    * `bundle exec rake rswag:specs:swaggerize`.
    * This will generate the file `swagger/v1/swagger.yaml`.
    * Please make sure to commit it.
* Visit the documentation:
    * [Documentation](https://allsearch-api.princeton.edu/api-docs)

### Validating the Swagger/OpenAPI schema file

This repo uses [vacuum](https://quobix.com/vacuum/about/) to validate that
the swagger.yaml file meets the OpenAPI standard.

```
brew install daveshanley/vacuum/vacuum
vacuum lint -d swagger/**/*.yaml
```
