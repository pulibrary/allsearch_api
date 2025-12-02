def create_banner_if_none_exists
  RomContainer.new.call.fmap do |rom|
    repo = RepositoryFactory.new(rom).banner
    return Rails.logger.info('Already have a banner object, update that one') if repo.banners.count >= 1

    repo.create({})
  end
end

create_banner_if_none_exists
