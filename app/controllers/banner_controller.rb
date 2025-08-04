# frozen_string_literal: true

class BannerController
  def self.call(env)
    banner_repo = BannerRepository.new env['rom']
    banner_json = banner_repo.banners.first.as_json
    [200, { 'Content-Type' => 'application/json; charset=utf-8' }, [banner_json]]
  end
end
