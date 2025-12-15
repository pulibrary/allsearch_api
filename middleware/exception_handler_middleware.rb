# frozen_string_literal: true

class ExceptionHandlerMiddleware
  ERROR_RESPONSE = [500, {}, ['{"error": {"problem": "ERROR", "message": "We encountered an error."}}']].freeze

  def initialize(app, honeybadger: Honeybadger)
    @app = app
    @honeybadger = honeybadger
  end

  def call(env)
    app.call env
  rescue StandardError => error
    honeybadger.notify(error)
    ERROR_RESPONSE
  end

  private

  attr_reader :app, :honeybadger
end
