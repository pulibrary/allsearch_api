# frozen_string_literal: true

class LibraryDatabaseController < ServiceController
  def initialize
    super
    @service = LibraryDatabase
  end
end
