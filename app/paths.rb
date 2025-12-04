# frozen_string_literal: true

def allsearch_path(path = '')
  Pathname.new "#{__dir__}/../#{path}"
end
