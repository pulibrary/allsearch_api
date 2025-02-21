# frozen_string_literal: true

class BannerController
  def self.call(_env)
    banner_json = Banner.first.as_json(except: [:id, :created_at, :updated_at])
    [200, { 'Content-Type' => 'application/json; charset=utf-8' }, [banner_json.to_json]]
  end
end
