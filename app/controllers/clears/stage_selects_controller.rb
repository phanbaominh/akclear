#  frozen_string_literal: true

class Clears::StageSelectsController < ApplicationController
  skip_before_action :authenticate!
  include ClearFilterable

  def show
    clear_spec_session.merge!(clear_params)
    set_clear_spec
    reset_stage_spec_if_needed
  end
end
