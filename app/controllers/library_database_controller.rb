# frozen_string_literal: true

class LibraryDatabaseController < RackResponseController
  def initialize(request)
    super
    @service = LibraryDatabase
  end
end
