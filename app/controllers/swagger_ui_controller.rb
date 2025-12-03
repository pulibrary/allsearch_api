# frozen_string_literal: true

# This module is responsible for serving human-readable API documentation
# using the third-party Swagger JS.
# Based on https://github.com/swagger-api/swagger-ui/blob/HEAD/docs/usage/installation.md#unpkg
module SwaggerUiController
  # rubocop:disable Metrics/MethodLength
  def self.call(_env)
    [
      200,
      {},
      [
        <<-END_HTML
            <!DOCTYPE html>
            <html lang="en">
              <head>
                <meta charset="utf-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1" />
                <meta name="description" content="SwaggerUI" />
                <title>SwaggerUI</title>
                <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5.11.0/swagger-ui.css" />
              </head>
              <body>
                <div id="swagger-ui"></div>
                <script src="https://unpkg.com/swagger-ui-dist@5.11.0/swagger-ui-bundle.js" crossorigin></script>
                <script>
                window.onload = () => {
                  window.ui = SwaggerUIBundle({
                  url: '/api-docs/v1/swagger.yaml',
                  dom_id: '#swagger-ui',
                  });
                };
              </script>
              </body>
            </html>
        END_HTML
      ]
    ]
  end
  # rubocop:enable Metrics/MethodLength
end
