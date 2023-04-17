# frozen_string_literal: true

class Clears::FiltersComponent < ApplicationComponent
  include Turbo::StreamsHelper
  include Turbo::FramesHelper

  attr_reader :clear_spec

  delegate :stageable, :operator_ids, to: :clear_spec

  def post_initialize(clear_spec:)
    @clear_spec = clear_spec
  end

  def all_stageables
    [Episode.all, Event.all].flatten
  end

  def selected_stageable
    [stageable.id, stageable.class.name].to_s if stageable.present?
  end

  def selectable_stages
    clear_spec.challenge_mode ? stageable.stages.challenge_mode : stageable.stages.non_challenge_mode
  end

  def selectable_operators
    Operator.all
  end
end
