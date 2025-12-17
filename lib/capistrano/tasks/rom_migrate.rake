# frozen_string_literal: true

# Override default Rails migrate step to run ROM/Sequel migrations instead
namespace :deploy do
  desc 'Run ROM/Sequel migrations'
  task :migrate do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :rake, 'rom:migrate'
        end
      end
    end
  end
end
