# frozen_string_literal: true

class Navbar::LinkComponent < ApplicationComponent
  def initialize(link:)
    @link = link
  end
end
