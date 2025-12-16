# frozen_string_literal: true

require_relative '../init/environment'

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
threads 5, 5

# Specifies the `worker_timeout` threshold that Puma will use to wait before
# terminating a worker in development environments.
#
CURRENT_ENVIRONMENT.when_development { worker_timeout 3600 }

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
# (you can still run `bundle exec puma -p 4567` to listen on another port)
port 3000

# Specifies the `environment` that Puma will run in.
#
environment CURRENT_ENVIRONMENT.name

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')
