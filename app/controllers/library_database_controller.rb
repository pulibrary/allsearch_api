# frozen_string_literal: true

class LibraryDatabaseController < ServiceController
  rescue_from ActionController::ParameterMissing, with: :show_query_errors

  def initialize
    super
    @service = LibraryDatabase
  end
end
