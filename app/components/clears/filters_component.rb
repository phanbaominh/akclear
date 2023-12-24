# frozen_string_literal: true

class Clears::FiltersComponent < ApplicationComponent
  attr_reader :clear_spec

  def initialize(clear_spec:)
    @clear_spec = clear_spec
  end

  def stageable_selected?
    clear_spec.stage_id.blank? && clear_spec.stageable_id.present?
  end

  def default_tab_name
    stageable_selected? ? 'detailed' : 'basic'
  end
end
