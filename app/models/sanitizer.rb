# frozen_string_literal: true

require 'sanitize'
require 'cgi'

class Sanitizer
  def sanitize(html)
    sanitized = sanitizer_implementation.fragment(html)
    with_fixed_whitespace = sanitized.strip.gsub(/(?:&nbsp;| )+/, ' ')
    CGI.unescapeHTML with_fixed_whitespace
  end

  private

  def sanitizer_implementation
    @sanitizer_implementation ||= Sanitize.new(elements: %w[b em i strong])
  end
end
