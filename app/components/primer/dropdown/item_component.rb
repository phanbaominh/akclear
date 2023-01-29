# frozen_string_literal: true

class Primer::Dropdown::ItemComponent < ApplicationComponent
  def post_initialize(link:, **options)
    @link = link
    @options = options
  end
end
