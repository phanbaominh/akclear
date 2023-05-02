# frozen_string_literal: true

class Clears::FiltersController < ApplicationController
  include ClearFilterable

  def show
    set_clear_spec
  end
end
