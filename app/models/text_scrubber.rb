# frozen_string_literal: true

class TextScrubber < Rails::HTML::PermitScrubber
  def initialize
    super
    # List of allowed HTML tags
    self.tags = %w( b em i p ul ol li h1 h2 h3 h4 h5 h6 )
  end

  def skip_node?(node)
    node.text?
  end
end
