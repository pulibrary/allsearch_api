# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from the Libanswers FAQ search JSON
class LibanswersDocument < Document
  def title
    document['question']
  end

  def id
    document['id'].to_s
  end

  def type
    'FAQ'
  end

  def url
    document['url'].gsub('\/', '/')
  end

  def topics
    document['topics']&.to_sentence
  end

  # not implemented for this API
  def creator; end
  # not implemented for this API
  def publisher; end
  # not implemented for this API
  def description; end

  def doc_keys
    [:topics]
  end
end
