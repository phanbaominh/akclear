# frozen_string_literal: true

class Clears::StageSelectsController < ApplicationController
  include ClearFilterable

  def show
    clear_spec_session.merge!(clear_spec_params)
    set_clear_spec
  end
end
