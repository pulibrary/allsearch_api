# frozen_string_literal: true

class ExtensionFilterMiddleware
  REJECTION = [403, {}, ['Invalid URL']].freeze
  def initialize(app)
    @app = app
  end

  def call(env)
    path = env['PATH_INFO']

    return REJECTION if path =~ /\.(?!json|yaml$)[^.]{1,5}$/

    @app.call(env)
  end
end
