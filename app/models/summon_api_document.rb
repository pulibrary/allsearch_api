# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from the Summon::Documents
class SummonApiDocument < Document
  delegate :abstract, to: :document
  delegate :end_page, to: :document
  delegate :issue, to: :document
  delegate :publication_title, to: :document
  delegate :publisher, to: :document
  delegate :start_page, to: :document
  delegate :volume, to: :document

  def title
    full_sanitizer = Rails::HTML5::FullSanitizer.new
    full_sanitizer.sanitize(document.title)
  end

  def creator
    document&.authors&.first&.fullname
  end

  def id
    document.src['DOI']&.first
  end

  def type
    document.content_type
  end

  # NOTE: the Snippet includes html to emphasize the relevant term, e.g.
  # In 1994, the Government of Cameroon introduced an array of <h>forest</h> policy reforms
  def description
    document.snippet
  end

  def url
    document.link
  end

  def doc_keys
    [:publication_date, :publication_year, :start_page, :end_page, :fulltext_available, :abstract,
     :publication_title, :volume, :issue, :isxn]
  end

  def fulltext_available
    document.fulltext
  end

  def isxn
    (isbn + issn).compact
  end

  def isbn
    (document.src['ISBN'].presence || [])
  end

  def issn
    (document.src['ISSN'].presence || [])
  end

  def publication_date
    document.publication_date.text
  end

  def publication_year
    document.publication_date.year
  end
end
