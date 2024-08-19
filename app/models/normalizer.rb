# frozen_string_literal: true

class Normalizer
  def initialize(term)
    @term = term
  end

  def without_diacritics
    @without_diacritics ||= begin
      diacritic_combining_characters = [*0x1DC0..0x1DFF, *0x0300..0x036F, *0xFE20..0xFE2F].pack('U*')
      decomposed_version = term.unicode_normalize(:nfd)
      decomposed_version.tr(diacritic_combining_characters, '')
    end
  end

  private

  attr_reader :term
end
