# frozen_string_literal: true

class BannerController
  def self.call(_env)
    banner_repo = RepositoryFactory.banner
    banner_json = banner_repo.first.as_json
    [200, { 'Content-Type' => 'application/json; charset=utf-8' }, [banner_json]]
  end
end
