# frozen_string_literal: true

# Override default Rails migrate step to run ROM/Sequel migrations instead
namespace :deploy do
  Rake::Task['deploy:migrate'].clear if Rake::Task.task_defined?('deploy:migrate')

  desc 'Run ROM/Sequel migrations'
  task :migrate do
    on roles(:db) do
      within release_path do
        with app_env: fetch(:app_env) do
          execute :bundle, :exec, :rake, 'db:migrate_to_rom'
        end
      end
    end
  end
end
