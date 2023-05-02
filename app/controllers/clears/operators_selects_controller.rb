class Clears::OperatorsSelectsController < ApplicationController
  include ClearFilterable

  def show
    clear_spec_session.merge!(clear_spec_params)
    @clear_spec_params = clear_spec_session
    set_clear_spec
  end
end
