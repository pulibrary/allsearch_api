# README
Backend API for [Princeton University Library's Allsearch application](https://allsearch.princeton.edu).

Requires:
- Ruby 3.4

[![Coverage Status](https://coveralls.io/repos/github/pulibrary/allsearch_api/badge.svg?branch=main)](https://coveralls.io/github/pulibrary/allsearch_api?branch=main)

## Getting started
1. Clone the repository - `git clone git@github.com:pulibrary/allsearch_api.git`
1. Go to the repository directory - `cd allsearch_api`
1. Install the required ruby version - `asdf install`
1. Install the required gems - `bundle install`
1. Make sure you have wget installed - `brew install wget`
1. Start local solr and postgres - `bundle exec rake servers:start`
1. Start the application server on localhost:3000 - `bundle exec rails s`
1. See the application running at http://localhost:3000/

## Run tests
### RSpec
To run all tests:
```bash
bundle exec rspec
```

We have a set of tests that test against the deployed staging environment. In order for these to pass, you must be on the VPN. To run these tests:
```bash
bundle exec rspec smoke_spec
```

To calculate coverage, run `COVERAGE=true bundle exec rspec`

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
1. If the service uses solr, [add some sample data](docs/sample-data.md).

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

## Update the banner
In order to update the banner at `/banner`, you can either update it on the rails console, or use a rake task.

Valid values for 'alert_status' are `info|success|warning|error`

### Run the rake task
There is a rake task that can accept multiple arguments. The arguments are `[text, alert_status, dismissible, autoclear]`. The arguments are comma delimited, with no spaces. If there is an argument you want to skip, just leave it blank, but leave any commas that might surround it (similar to a csv file). Depending on your shell, you may need to escape the brackets surrounding the arguments.

If there are any commas in your text, you will need to escape them using `\`

#### Setting all four values:
```zsh
bundle exec rake banner:update\['new banner',info,true,true\]
```
#### Setting only text and autoclear
```zsh
bundle exec rake banner:update\['newer banner',,,false\]
```
#### Setting long text in multiple steps
```zsh
LONG_HTML="<h2>All-Search Updated</h2><p> Introducing our new and improved All-Search\, upgraded with advanced technology and designed based on your feedback to enhance your research experience. Share your experience and help us improve it further by completing this <a href='https://example.com'>brief survey</a></p>"
bundle exec rake banner:update\["$LONG_HTML",'info',true,false\]
```

## Set the banner to visible or not visible
### Via Capistrano
Can be run locally against a remote environment. Must be on VPN.
```zsh
bundle exec cap staging banner:enable
bundle exec cap staging banner:disable
```

### Via the Flipper CLI
Must be done on the environment where you want to change it
```bash
bundle exec flipper enable banner
bundle exec flipper disable banner
```

## Use the permanent website url
### Via the Flipper CLI
Must be done on the environment where you want to change it
```bash
bundle exec flipper enable permanent_host # sets library host to library.princeton.edu
bundle exec flipper disable permanent_host # sets library host to library.psb-prod.princeton.edu
```
