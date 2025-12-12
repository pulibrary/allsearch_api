# frozen_string_literal: true

require allsearch_path 'init/rom_factory'

# Flipper must be required after a database connection is established
# However, we may be in a context where the database is not yet available
# (e.g. rake servers:start), so we don't throw an error if we can't setup
# the database or flipper

case RomFactory.new.database_if_available
in Success
  begin
    require 'flipper-sequel'
  rescue Sequel::Error
    nil
  end
in Failure
  nil
end
