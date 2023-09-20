# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from the Libanswers FAQ search JSON
class LibanswersDocument < Document
  def title
    json['question']
  end

  def id
    json['id'].to_s
  end

  def type
    'FAQ'
  end

  def url
    json['url'].gsub('\/', '/')
  end

  def topics
    json['topics']&.to_sentence
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
