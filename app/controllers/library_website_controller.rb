# frozen_string_literal: true

class LibraryWebsiteController < RackResponseController
  def initialize(request, env)
    super
    @service = LibraryWebsite
  end
end
