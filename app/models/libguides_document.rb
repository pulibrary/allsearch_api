# frozen_string_literal: true

require 'dry-monads'

class LibguidesDocument < Document
  include Dry::Monads[:maybe]

  def title
    document['name']
  end

  def creator
    Maybe(guide_owner).bind do |owner|
      if owner.empty?
        None()
      else
        Some("#{owner['first_name']} #{owner['last_name']}")
      end
    end.value_or(nil)
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
    sanitize document['description']
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
