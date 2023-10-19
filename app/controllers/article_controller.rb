# frozen_string_literal: true

class ArticleController < ServiceController
  def initialize
    super
    @service = Article
  end
end
