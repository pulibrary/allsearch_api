# frozen_string_literal: true

RSpec::Matchers.define :increase_allocations_no_more_than do |allocation_limit|
  match do |block_to_test|
    GC.disable
    total_start = GC.stat[:total_allocated_objects]
    block_to_test.call
    total_end = GC.stat[:total_allocated_objects]
    GC.enable

    @total_allocations = total_end - total_start
    @total_allocations <= allocation_limit
  end

  failure_message do
    "expected to allocate no more than #{allocation_limit} objects, but allocated #{@total_allocations} objects"
  end

  def supports_block_expectations? = true
end
