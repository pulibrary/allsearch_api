# frozen_string_literal: true

class MainController < ApplicationController
  def index
    render json: Main.info
  end
end
