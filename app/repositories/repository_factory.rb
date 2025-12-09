# frozen_string_literal: true

class RepositoryFactory
  [:banner, :library_database, :library_staff, :oauth_token].each do |method_name|
    define_singleton_method method_name do
      return instance_variable_get("@#{method_name}") if instance_variable_defined?("@#{method_name}")

      instance_variable_set("@#{method_name}", new.send(method_name))
    end
  end

  # Over time, we can gradually move from Rails.application.config.rom (the Rails way to access ROM)
  # to env['rom'] (the Rack way)
  def initialize(rom = Rails.application.config.rom)
    @rom = rom
  end

  def banner
    BannerRepository.new(rom)
  end

  def library_database
    LibraryDatabaseRepository.new(rom)
  end

  def oauth_token
    OAuthTokenRepository.new(rom)
  end

  def library_staff
    LibraryStaffRepository.new(rom)
  end

  private

  attr_reader :rom
end
