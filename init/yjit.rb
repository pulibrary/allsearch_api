# frozen_string_literal: true

# This should be near the end of init process, so we don't needlessly
# compile the startup code that we won't use again
RubyVM::YJIT.enable
