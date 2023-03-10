# frozen_string_literal: true

class Primer::PagyComponent < ApplicationComponent
  include Pagy::Frontend
  attr_reader :pagy

  def post_initialize(pagy:)
    @pagy = pagy
  end
end
