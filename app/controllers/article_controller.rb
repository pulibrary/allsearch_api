# frozen_string_literal: true

class ArticleController < RackResponseController
  def initialize(request, env)
    super
    @service = Article
  end
end
