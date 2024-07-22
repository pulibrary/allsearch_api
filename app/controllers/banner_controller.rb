# frozen_string_literal: true

class BannerController < ApplicationController
  def show
    banner_json = Banner.first.as_json(except: [:id, :created_at, :updated_at])

    render json: banner_json
  end
end
