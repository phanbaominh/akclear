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

  def challengable?
    stageable.challengable? && (
      !stageable.is_a?(Episode) ||
      !stageable.episode_9? || clear_spec.environment == Episode::Environment::STANDARD
    )
  end

  def selectable_environments
    Episode::Environment.available_environments(stageable)
  end

  def selectable_stages
    base = stageable.stages
    if clear_spec.challenge_mode
      base.challenge_mode
    elsif clear_spec.environment
      base.with_environment(clear_spec.environment).non_challenge_mode
    else
      base.non_challenge_mode
    end
  end
end
