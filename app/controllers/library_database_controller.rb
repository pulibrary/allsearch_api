# frozen_string_literal: true

class LibraryDatabaseController < RackResponseController
  def initialize(request, env)
    super
    @service = LibraryDatabase
  end
end
