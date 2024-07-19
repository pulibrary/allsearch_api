# frozen_string_literal: true

require 'rails-html-sanitizer'
require 'cgi'

class Sanitizer < Rails::HTML5::SafeListSanitizer
  def sanitize(html, options = {})
    # Add spaces before opening HTML tags, so that words don't run together
    # after the tags are removed
    with_spaces = html.to_s.gsub(/(\S)(<\w)/, '\1 \2')
    sanitized = super(with_spaces, options).gsub('&nbsp;', ' ').strip
    CGI.unescapeHTML sanitized
  end
end
