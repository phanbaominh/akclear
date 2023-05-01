class Clears::OperatorsSelectsController < ApplicationController
  include ClearFilterable

  def show
    set_clear_spec_session
  end
end
