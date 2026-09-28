# frozen_string_literal: true

class BannerController
  def initialize(banner_repo: RepositoryFactory.banner)
    @banner_repo = banner_repo
  end

  def call(_env)
    banner_json = banner_repo.first.as_json
    [200, { 'Content-Type' => 'application/json; charset=utf-8' }, [banner_json]]
  end

  private

  attr_reader :banner_repo
end
