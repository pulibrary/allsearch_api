# frozen_string_literal: true

class AllsearchError < StandardError
  attr_reader :problem

  def initialize(msg:, problem: 'UPSTREAM_ERROR')
    @problem = problem
    super(msg)
  end
end
