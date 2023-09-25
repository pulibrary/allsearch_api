# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:3000',
            'http://127.0.0.1:3000',
            %r{\Ahttps://[\w-]+\.princeton.edu\Z}

    resource '/search/*', headers: :any, methods: [:get, :head]
  end
end
