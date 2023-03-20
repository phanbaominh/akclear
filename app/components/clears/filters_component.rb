# frozen_string_literal: true

class Clears::FiltersComponent < ApplicationComponent
  include Turbo::StreamsHelper
  include Turbo::FramesHelper

  attr_reader :searched_clear, :stageable, :operator_ids

  def post_initialize(searched_clear:, stageable:, operator_ids:)
    @searched_clear = searched_clear
    @stageable = stageable
    @operator_ids = operator_ids
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
    stageable.stages
  end

  def selected_stage
    searched_clear&.stage
  end

  def operators_select_data
    Operator.first(5).map do |operator|
      {
        value: operator.id.to_s,
        label: operator.name,
        customProperties: {
          avatar: operator.avatar,
          selected: initial_operators_ids.include?(operator.id)
        }
      }
    end.to_json

  def selectable_operators
    Operator.all
  end
end
