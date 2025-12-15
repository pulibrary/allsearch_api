# frozen_string_literal: true

require 'sanitize'
require 'cgi'

class Sanitizer
  def sanitize(html)
    remove_problematic_html(html)
      .gsub('&nbsp;', ' ')
      .squeeze(' ')
      .strip
  end

  private

  def remove_problematic_html(raw)
    html = raw.to_s
    if html.include? '<'
      sanitizer_implementation.fragment(html)
    else
      # If there is not an angle bracket, no need to parse it as HTML
      html
    end
  end

  # :reek:FeatureEnvy
  def sanitizer_implementation
    @sanitizer_implementation ||= begin
      remove_entities = lambda do |env|
        node = env[:node]
        if node.is_a? Nokogiri::XML::Text
          sanitized = Sanitize.fragment(CGI.unescapeHTML(node.content))
          sanitized.tr("\u00A0", ' ')
        end
      end
      Sanitize.new(elements: %w[b em i strong], transformers: remove_entities)
    end
  end
end
