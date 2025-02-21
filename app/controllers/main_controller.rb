# frozen_string_literal: true

class MainController
  def self.call(_env)
    [200, { 'Content-Type' => 'application/json; charset=utf-8' }, [Main.info.to_json]]
  end
end
