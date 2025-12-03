# frozen_string_literal: true

require_relative '../app/router'

Rails.application.routes.draw do
  get '/', to: Router
  get '/*', to: Router
end
