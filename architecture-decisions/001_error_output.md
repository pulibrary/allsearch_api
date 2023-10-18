# 1. Error output

Date: 2023-10-18

## Status

Draft

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
* For any of these status codes except 200, we will return a JSON
object in the following format:
    ```
    {
        error: {
            code: "QUERY_IS_EMPTY",
            message: "The query param must contain non-whitespace characters."
        }
    }
    ```
    The codes should be unlikely to change over time, so that client
    applications can rely on them.
    The message should offer helpful troubleshooting information, with
    the audience of client application developers.
* We will make sure that errors make it through the load balancer, rather
than being converted into the generic "Looks like something went wrong!" page.
* For any errors produced at the application level,
we will include an example of the error response in
swagger.

## Consequences

* We won't be able to be as specific with our HTTP error
codes.
* We will have to add and maintain code and nginx configurations
to ensure the consistent error responses.
