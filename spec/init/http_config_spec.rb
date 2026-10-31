# frozen_string_literal: true

require 'spec_helper'
require allsearch_path 'init/http_config'

RSpec.describe HTTPConfig do
  describe '#call' do
    it 'configures Net::HTTP to timeout before 10 seconds (when the LB will consider it unhealthy)' do
      described_class.new.call
      http = Net::HTTP.new('princeton.edu')
      expect(http.read_timeout + http.write_timeout).to be < 10
    end
  end
end
