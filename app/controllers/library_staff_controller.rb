# frozen_string_literal: true

class LibraryStaffController < RackResponseController
  def initialize(request, env)
    super
    @service = LibraryStaff
  end
end
