# frozen_string_literal: true

class Clears::StageSelectsController < ApplicationController
  include ClearFilterable

  def show
    @clear_spec = Clear::Specification.new(**(clear_spec_params.to_h || {}))
  end
end
