# frozen_string_literal: true

class ExtensionFilterMiddleware
    REJECTION = [403, {}, ['Invalid URL']].freeze
    def initialize(app)
        @app = app
    end

    def call(env)
        path = env['PATH_INFO']

        if path =~ /\.(?!json|yaml$)[^.]{1,5}/
            return REJECTION
        end
        @app.call(env)
    end
end
