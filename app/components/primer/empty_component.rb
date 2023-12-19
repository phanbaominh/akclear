# frozen_string_literal: true

class Primer::EmptyComponent < ApplicationComponent
  attr_reader :title, :text

  def post_initialize(title:, text:)
    @title = title
    @text = text
  end
end
