# frozen_string_literal: true

class LibraryWebsiteController < RackResponseController
  def initialize(request)
    super
    @service = LibraryWebsite
  end
end
