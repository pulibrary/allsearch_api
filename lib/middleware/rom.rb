# frozen_string_literal: true

# This middleware is responsible for making a ROM container available to
# other Rack middlewares and applications
class RomMiddleware
  def initialize(app, rom_container)
    @app = app
    @rom_container = rom_container
  end

  def call(env)
    env['rom'] = rom_container
    app.call env
  end

  private

  attr_reader :app, :rom_container
end
