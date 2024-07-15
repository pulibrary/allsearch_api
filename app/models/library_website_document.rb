# frozen_string_literal: true

class LibraryWebsiteDocument < Document
  def title
    document['title']
  end

  def id
    document['nid']
  end

  def url
    document['url']
  end

  def description
    sanitize document['body']
  end

  def type
    document['bundle']
  end

  # not implemented for this API
  def creator; end
  # not implemented for this API
  def publisher; end

  def doc_keys
    []
  end
end
