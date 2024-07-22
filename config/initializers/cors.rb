# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins %r{\Ahttp://localhost(:\d+)?\Z},
            %r{\Ahttp://127.0.0.1(:\d+)?\Z},
            %r{\Ahttps://[\w-]+\.princeton.edu\Z}

    resource '/search/*', headers: :any, methods: [:get, :head]
    resource '/banner', headers: :any, methods: [:get, :head]
  end
end
