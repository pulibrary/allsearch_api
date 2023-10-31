# frozen_string_literal: true

class LibguidesDocument < Document
  def title
    document['name']
  end

  def creator
    return if guide_owner.blank?

    "#{guide_owner['first_name']} #{guide_owner['last_name']}"
  end

  def publisher
    'Princeton University Library'
  end

  def id
    document['id'].to_s
  end

  def type
    document['type_label']
  end

  def description
    ActionView::Base.full_sanitizer.sanitize(document['description'])
  end

  def url
    document['friendly_url'] || document['url']
  end

  def doc_keys
    []
  end

  private

  def guide_owner
    @guide_owner ||= document['owner']
  end
end
