# frozen_string_literal: true

class ArticleController < RackResponseController
  def initialize(request, env = nil)
    super
    @service = Article
  end
end
