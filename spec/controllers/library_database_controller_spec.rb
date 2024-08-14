# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/service_controller_shared_examples'

RSpec.describe LibraryDatabaseController do
  it_behaves_like 'a service controller'
end
