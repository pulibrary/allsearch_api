# frozen_string_literal: true

# :reek:UtilityFunction
module Tokenizer
  extend self

  def tokenize(string) = string.split(/[[[:space:]]\p{Pd}]/)
end
