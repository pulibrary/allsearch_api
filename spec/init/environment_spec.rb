# frozen_string_literal: true

require 'spec_helper'
require allsearch_path 'init/environment'

RSpec.describe 'Environment' do
  describe '#when_development' do
    it 'runs the provided block if in the development environment' do
      block_was_called = false
      Environment.new({ 'RAILS_ENV' => 'development' }).when_development { block_was_called = true }
      expect(block_was_called).to be true
    end

    it 'runs the provided block if the environment variables do not provide an environment' do
      block_was_called = false
      Environment.new({}).when_development { block_was_called = true }
      expect(block_was_called).to be true
    end

    it 'does not run the provided block in production' do
      block_was_called = false
      Environment.new({ 'RAILS_ENV' => 'production' }).when_development { block_was_called = true }
      expect(block_was_called).to be false
    end

    it 'can be chained with #when_deployed' do
      first_block_was_called = false
      second_block_was_called = false
      Environment.new({ 'RAILS_ENV' => 'staging' })
                 .when_development { first_block_was_called = true }
                 .when_deployed { second_block_was_called = true }
      expect(first_block_was_called).to be false
      expect(second_block_was_called).to be true
    end
  end
end
