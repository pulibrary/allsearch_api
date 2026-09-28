# frozen_string_literal: true

class ArticleController < RackResponseController
  def initialize(...)
    super
    @service = Article
  end
end
