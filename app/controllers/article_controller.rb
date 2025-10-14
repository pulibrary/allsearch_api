# frozen_string_literal: true

class ArticleController < RackResponseController
  def initialize(request)
    super
    @service = Article
  end
end
