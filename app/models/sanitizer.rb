# frozen_string_literal: true

require 'rails-html-sanitizer'

class Sanitizer < Rails::HTML5::SafeListSanitizer
  def sanitize(html, options = {})
    # Add spaces before opening HTML tags, so that words don't run together
    # after the tags are removed
    with_spaces = html.gsub(/(\S)(<\w)/, '\1 \2')
    sanitized = super(with_spaces, options)
    sanitized.gsub('&nbsp;', ' ').strip
  end
end
