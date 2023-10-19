# 1. Error output

Date: 2023-10-18

## Status

Accepted

## Context

There are many reasons why a request to this application might result in an
error, including:

* Passenger is not running
* A client application makes a bad request to this application (e.g.
does a search with an empty query)
* This application fails to authenticate to an upstream application
* This application makes a bad query/request to an upstream application
* The upstream application is down
* The client request has made too many requests and is now rate limited

When such an error happens, a client application will need to handle it,
whether the error is ultimately the fault of this application or the client.

## Decision

* We will only respond to requests using the following HTTP status codes,
to limit the number of possible status codes a client application would
need to know how to handle:
    * 200 OK
    * 400 Bad Request
    * 403 Forbidden (requests to the staging api when not on the VPN)
    * 404 Not Found
    * 413 Payload Too Large (handled by the `client_max_body_size`) directive
    on the load balancer
    * 429 Too Many Requests
    * 500 Internal Server Error
* For any of these status codes except 200, the response body will
be in the following format:
    ```
    {
        error: {
            problem: "QUERY_IS_EMPTY",
            message: "The query param must contain non-whitespace characters."
        }
    }
    ```
    The `problem` string will provide additional information about what caused the
    error, beyond what is provided by the HTTP status code.  Client applications
    should be able to rely on the `problem` string, so these strings should be
    succinct and not change over time.

    The `message` string should offer helpful troubleshooting information, with
    the audience of client application developers.  Client applications should
    not base any logic on these `message` strings, since they may be verbose and
    change over time.

    The `problem` and `message` don't have a 1:1 relationship with the HTTP status
    code.  For example, the HTTP status code 400 could refer to a wide range of
    potential `problems`, not just `QUERY_IS_EMPTY`.  If our application sends a
    400 response, it should also send a more specific `problem` and `message`.
* We will make sure that these JSON response bodies make it through the load
balancer, rather than being converted into the generic "Looks like something
went wrong!" page.
* For any errors produced at the application level,
we will include an example of the error response in
swagger.

## Consequences

* We won't be able to be as specific with our HTTP error
codes.
* We will have to add and maintain code and nginx configurations
to ensure the consistent error responses.
