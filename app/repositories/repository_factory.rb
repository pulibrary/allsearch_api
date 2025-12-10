# frozen_string_literal: true

class RepositoryFactory
  [:banner, :library_database, :library_staff, :oauth_token].each do |method_name|
    define_singleton_method method_name do
      return instance_variable_get("@#{method_name}") if instance_variable_defined?("@#{method_name}")

      rom = Rails.application.config.rom
      instance_variable_set("@#{method_name}", new(rom).send(method_name))
    end
  end

  def initialize(rom)
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
