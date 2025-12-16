# frozen_string_literal: true

# This class is responsible for initializing the Rails application.
# It is an override of Rails.application.initialize!
class InitializeRails
  INITIALIZERS_TO_INCLUDE = ['active_record.set_configs', 'active_record.initialize_database',
                             :load_config_initializers].freeze

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
                                        .select { INITIALIZERS_TO_INCLUDE.include? it.name }
  end

  def rails_initializers_have_run?
    application.instance_variable_get(:@ran) || application.instance_variable_get(:@initialized)
  end
end
