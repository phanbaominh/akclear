# frozen_string_literal: true

class Clears::StageSelectComponent < ApplicationComponent
  include Turbo::FramesHelper
  attr_reader :form, :multiple, :simple, :stage_label, :required

  delegate :stageable, to: :clear_spec

  def post_initialize(form:, multiple: false, simple: false, stage_select_path: nil, stage_label: nil, required: false)
    @form = form
    @multiple = multiple
    @simple = simple
    @stage_select_path = stage_select_path
    @stage_label = stage_label
    @required = required
  end

  def stage_select_path
    @stage_select_path || clears_stage_select_path
  end

  def clear_spec
    form.object
  end

  def annihilation?
    stage_type == Annihilation
  end

  def stage_type
    clear_spec.stage_type.constantize if clear_spec.stage_type.present?
  end

  def stageables
    stage_type.selectable
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

  def all_stages
    Stage.all.includes(:stageable)
  end

  def selectable_stages
    return Stage.where(stageable_type: Annihilation.to_s).includes(:stageable) if annihilation?

    base = stageable.stages.includes(:stageable)

    if clear_spec.challenge_mode
      base.challenge_mode
    elsif clear_spec.environment
      base.with_environment(clear_spec.environment).non_challenge_mode
    else
      base.non_challenge_mode
    end
  end
end
