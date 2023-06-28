# frozen_string_literal: true

class Clears::StageSelectComponent < ApplicationComponent
  include Turbo::FramesHelper
  attr_reader :form

  delegate :stageable, to: :clear_spec

  def post_initialize(form:)
    @form = form
  end

  def clear_spec
    form.object
  end

  def stage_type
    clear_spec.stage_type&.constantize
  end

  def stageables
    stage_type.all
  end

  def selectable_stages
    clear_spec.challenge_mode ? stageable.stages.challenge_mode : stageable.stages.non_challenge_mode
  end
end
