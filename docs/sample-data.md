### Sample data

This repository includes sample data for solr, to assist with local development.
The sample data are automatically loaded when you start the development server.

Each solr core includes at least five documents matching "cats", and at least
one document matching "penguins".

#### Adding more sample data

1. `ssh -L 7872:localhost:8983 pulsys@lib-solr-staging6`
1. `bundle exec rake solr:create_sample_data\[giraffe,dpul-staging,dpul-giraffe.json\]`
    * In this example, `giraffe` is the query, `dpul-staging` is the collection to search, and `dpul-giraffe.json` is what the file should be called when saved.
