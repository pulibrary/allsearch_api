# frozen_string_literal: true

class LibraryDatabaseController < RackResponseController
  def initialize(request, env = nil)
    super
    @service = LibraryDatabase
  end
end
