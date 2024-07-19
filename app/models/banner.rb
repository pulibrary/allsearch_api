# frozen_string_literal: true

# This class is responsible for coordinating displaying an informational banner
class Banner < ApplicationRecord
  enum alert_status: {
    info: 1,
    success: 2,
    warning: 3,
    error: 4
  }

  def display_banner
    @display_banner = Flipper.enabled?(:banner)
  end

  # args is an instance of Rake::TaskArguments
  def rake_update(args)
    update(args.to_h)
    save!
  end
end
