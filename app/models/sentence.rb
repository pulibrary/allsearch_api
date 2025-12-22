# frozen_string_literal: true

class Sentence
  def initialize(array)
    @array = array
  end

  def call
    case length
    when 0
      ''
    when 1..2
      array.join(' and ')
    else
      (first_part + last_part).join(', ')
    end
  end

  private

  attr_reader :array

  def length
    array&.length || 0
  end

  def first_part
    array[0...-1]
  end

  def last_part
    ["and #{array[-1]}"]
  end
end
