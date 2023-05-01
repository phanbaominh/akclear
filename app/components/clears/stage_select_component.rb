# frozen_string_literal: true

class Clears::StageSelectComponent < ApplicationComponent
  include Turbo::FramesHelper
  attr_reader :form

  delegate :stageable, to: :stage_selectable

  def post_initialize(form:)
    @form = form
  end

  def stage_selectable
    form.object
  end

  def all_stageables
    [Episode.all, Event.all].flatten
  end

  def selectable_stages
    stage_selectable.challenge_mode ? stageable.stages.challenge_mode : stageable.stages.non_challenge_mode
  end
end
