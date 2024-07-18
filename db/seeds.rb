def create_banner_if_none_exists
  return Rails.logger.info('Already have a banner object, update that one') if Banner.count >= 1

  Banner.create!
end

create_banner_if_none_exists
