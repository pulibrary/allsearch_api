---
name: Add a New Service
about: Add a New Service EndPoint to the API
title: 'Add New .... to the API'
labels: ''
assignees: ''

---

## Description

### Source Service End User URL

### Supporting Service Documentation

### Connectivity

### Acceptance Criteria

- [ ] Returns the results to the equivalent of  a basic keyword query of the service
- [ ] Provides Search results with the same default sort as the native service
  interface 
- [ ] API response should include a count of the total results
- [ ] API response should include a "more results" link to the native interface, so that a user can continue their search there
- [ ] API response should include the first 3 results from the source
  application
- [ ] API Resource should include the following fields
    * Title Field
    * Individual URL for each result returned
    * Add others accordingly to this checklist
    * .......
- [ ] Inputs are sanitized (inheriting your Controller from `ServiceController` will
do this automatically)
- [ ] The new endpoint is added to the swagger documentation

### Implementation Notes

* See the [README](https://github.com/pulibrary/allsearch_api#create-a-new-service) for more details about how to create a new service
