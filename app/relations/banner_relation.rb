# frozen_string_literal: true

ALERT_STATUS_CODES = {
  1 => 'info',
  2 => 'success',
  3 => 'warning',
  4 => 'error'
}.freeze

# This relation is responsible for reading data from the banners database table
class BannerRelation < ROM::Relation[:sql]
  STATUS = ROM::Types::Coercible::Integer.enum(ALERT_STATUS_CODES)
  schema :banners, infer: true do
    attribute :alert_status, STATUS, null: false
  end
end
