# frozen_string_literal: true

class LibraryDatabaseController < RackResponseController
  def initialize(...)
    super
    @service = LibraryDatabase
  end
end
