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
    [Episode.all, Event.all].flatten.map do |stageable|
      [stageable.name, [stageable.id, stageable.class.name]]
    end
  end

  def selected_stageable
    [stageable.id, stageable.class.name].to_s if stageable.present?
  end

  def selectable_stages
    stageable.stages.non_challenge_mode
  end

  def selected_stage
    clear_spec.stage
  end

  def challenge_mode?
    selected_stage&.challenge_mode? || false
  end

  def selectable_operators
    Operator.all
  end
end
