# frozen_string_literal: true

class LibraryStaffController < RackResponseController
  def initialize(service)
    super
    @service = LibraryStaff
  end
end
