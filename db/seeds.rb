require allsearch_path('init/logger')
require allsearch_path('init/rom_factory')

def create_banner_if_none_exists
  RomFactory.new.rom_if_available.fmap do |rom|
    repo = RepositoryFactory.new(rom).banner
    return ALLSEARCH_LOGGER.info('Already have a banner object, update that one') if repo.banners.count >= 1

    repo.create({})
  end
end

create_banner_if_none_exists
