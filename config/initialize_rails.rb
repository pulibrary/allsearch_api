# frozen_string_literal: true

# This class is responsible for initializing the Rails application.
# It is an override of Rails.application.initialize!
# We can gradually exclude more of Rails' built-in
# initializers as we migrate away from Rails
class InitializeRails
  INITIALIZERS_TO_EXCLUDE = [
    :set_autoload_paths, :setup_once_autoloader, :setup_main_autoloader,
    :set_eager_load, :set_eager_load_paths, :eager_load!,
    :initialize_logger
  ].freeze

  def initialize(application = Rails.application)
    @application = application
  end

  def call
    initializers_to_run.each { it.run Rails.application }
    application.instance_variable_set(:@ran, true)
    application.instance_variable_set(:@initialized, true)
  end

  private

  attr_reader :application

  def initializers_to_run
    @initializers_to_run ||= application.initializers.tsort_each
                                        .select { it.belongs_to? :default }
                                        .reject { INITIALIZERS_TO_EXCLUDE.include? it.name }
  end

  def rails_initializers_have_run?
    application.instance_variable_get(:@ran) || application.instance_variable_get(:@initialized)
  end
end
