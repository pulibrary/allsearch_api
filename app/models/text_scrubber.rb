# frozen_string_literal: true

require 'rails-html-sanitizer'

class TextScrubber < Rails::HTML::PermitScrubber
  def initialize
    super
    # List of allowed HTML tags
    self.tags = %w[b em i strong]
  end
end
