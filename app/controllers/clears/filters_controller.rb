# frozen_string_literal: true

class Clears::FiltersController < ApplicationController
  skip_before_action :authenticate!
  include ClearFilterable

  def show
    set_clear_spec
  end
end
