# frozen_string_literal: true

class LibraryStaffController < ServiceController
  def initialize
    super
    @service = LibraryStaff
  end
end
