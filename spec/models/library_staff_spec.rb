# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryStaff do
  let(:staff_service) { described_class.new(query_terms: 'foo') }

  it 'has the correct more_link' do
    expect(staff_service.more_link.to_s).to eq('https://library.princeton.edu/about/staff-directory?combine=foo')
  end
end
