# frozen_string_literal: true

require 'sanitize'
require 'cgi'

class Sanitizer
  def sanitize(html)
    sanitized = remove_problematic_html(html)
      .gsub('&nbsp;', ' ')
      .squeeze(' ')
      .strip
    CGI.unescapeHTML(sanitized)
  end

  private

  def remove_problematic_html(raw)
    html = raw.to_s
    if html.include? '<'
      # We CGI.unescapeHTML before parsing the HTML to make sure
      # that the original string can't sneak in, say,
      # a malicious <script> as &lt;script&gt;
      sanitizer_implementation.fragment(CGI.unescapeHTML(html))
    else
      # If there is not an angle bracket, no need to parse it as HTML
      html
    end
  end

  def sanitizer_implementation
    @sanitizer_implementation ||= Sanitize.new(elements: %w[b em i strong])
  end
end
