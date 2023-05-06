# frozen_string_literal: true

class Clears::AsideComponent < ApplicationComponent
  attr_reader :clears, :title

  def post_initialize(clears:, title:)
    @clears = clears
    @title = title
  end
end
