# frozen_string_literal: true

require 'rom-repository'
require 'flipper'

# This repository translates between the objects and methods in our repository and the data and queries in our database
# To instantiate:
# br = BannerRepository.new env['rom']
# br.banners.first
class BannerRepository < ROM::Repository[:banners]
  def modify(new_values)
    existing_banner = banners.first
    if existing_banner
      update existing_banner.id, new_values
    else
      create new_values
    end
  end

  def delete
    # There should only ever be one, banner, so it is safe to delete them all
    banners.changeset(:delete).commit
  end

  commands :create,
           use: :timestamps,
           plugins_options: { timestamps: { timestamps: [:created_at, :updated_at] } }

  commands update: :by_pk,
           use: :timestamps,
           plugins_options: { timestamps: { timestamps: [:updated_at] } }

  module Structs
    # This struct represents a row from the banners database table
    class Banner < ROM::Struct
      # :reek:UtilityFunction
      def display?
        Flipper.enabled?(:banner)
      end

      def status_code
        ALERT_STATUS_CODES[alert_status]
      end

      def as_json
        {
          text:,
          display_banner: display?,
          alert_status: status_code,
          dismissible:,
          autoclear:
        }.to_json
      end
    end
  end
  auto_struct true
  struct_namespace Structs
end
