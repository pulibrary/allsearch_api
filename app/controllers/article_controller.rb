# frozen_string_literal: true

class ArticleController < ServiceController
  rescue_from ActionController::ParameterMissing, with: :show_query_errors

  def initialize
    super
    @service = Article
  end
end
