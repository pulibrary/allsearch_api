def create_banner_if_none_exists
  repo = RepositoryFactory.banner
  return Rails.logger.info('Already have a banner object, update that one') if repo.banners.count >= 1

  repo.create({})
end

create_banner_if_none_exists
