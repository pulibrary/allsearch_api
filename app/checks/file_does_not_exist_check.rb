# frozen_string_literal: true

require 'dry-monads'

class FileDoesNotExistCheck
  include Dry::Monads[:result]

  def initialize(path)
    @path = path
  end

  def call
    if File.exist? path
      Failure("Unwanted file #{path} exists!")
    else
      Success()
    end
  end

  private

  attr_reader :path
end
