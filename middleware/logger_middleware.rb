# frozen_string_literal: true

class LoggerMiddleware
  def initialize(app, logger = ALLSEARCH_LOGGER)
    @app = app
    @logger = logger
  end

  def call(env)
    RequestLogger.new(app:, env:, logger:).call
  end

  private

  attr_reader :app, :logger

  class RequestLogger
    def initialize(app:, logger:, env:)
      @app = app
      @logger = logger
      @env = env
    end

    # rubocop:disable Metrics/AbcSize
    def call
      start_allocations = current_allocations
      response = app.call(env)
      end_allocations = current_allocations
      logger.info 'Response',
                  { code: response[0], allocations: (end_allocations - start_allocations),
                    method: env['REQUEST_METHOD'], ip: request.ip }
      response
    rescue StandardError => error
      logger.error error.message
      raise error
    end
    # rubocop:enable Metrics/AbcSize

    private

    attr_reader :app, :env, :logger

    def request
      @request ||= Rack::Request.new(env)
    end

    def current_allocations
      GC.stat(:total_allocated_objects)
    end
  end
end
