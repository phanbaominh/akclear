# frozen_string_literal: true

class Clears::FiltersComponent < ApplicationComponent
  attr_reader :clear_spec

  def initialize(clear_spec:)
    @clear_spec = clear_spec
  end
end
