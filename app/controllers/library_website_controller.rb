# frozen_string_literal: true

class LibraryWebsiteController < ServiceController
  def initialize
    super
    @service = LibraryWebsite
  end
end
