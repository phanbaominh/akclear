# frozen_string_literal: true

module Clear::Specifiable
  extend ActiveSupport::Concern

  included do
    attribute :challenge_mode, :boolean
    attribute :environment, :string
    attribute :stageable_id, :string
    attribute :stage_type, :string

    validates :stage_type, inclusion: { in: Stage::STAGEABLE_TYPES }, allow_blank: true
  end

  def environment
    Episode::Environment.new(super) if super
  end

  def stageable
    attributes[:stageable_id] ? GlobalID::Locator.locate(stageable_id) : stage&.stageable
  end

  # autofill value when only stage_id is present
  def stageable_id
    super || stageable&.to_global_id
  end

  # autofill value when only stage_id is present
  def stage_type
    super || stageable&.class&.name
  end

  def stage_id
    stageable.is_a?(Annihilation) ? stageable.stages.first.id : super
  end

  def challenge_mode=(value)
    if stageable&.challengable?
      super
    else
      super nil
    end
  end

  def environment=(value)
    if stageable&.has_environments?
      super
    else
      super nil
    end
  end

  def reset_spec
    self.stage_id = nil
    self.stageable_id = nil
    self.environment = nil
    self.challenge_mode = nil
  end
end
