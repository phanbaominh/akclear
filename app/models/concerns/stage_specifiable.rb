module StageSpecifiable
  extend ActiveSupport::Concern
  attr_writer :stageable_id, :stage_type
  attr_reader :challenge_mode

  included do
    respond_to?(:validates) do
      validates :stage_type, inclusion: { in: Stage::STAGEABLE_TYPES }, allow_blank: true
    end
  end

  def environment
    Episode::Environment.new(@environment) if @environment
  end

  def stageable
    @stageable_id ? GlobalID::Locator.locate(stageable_id) : stage&.stageable
  end

  # autofill value when only stage_id is present
  def stageable_id
    @stageable_id || stageable&.to_global_id
  end

  # autofill value when only stage_id is present
  def stage_type
    @stage_type || stageable&.class&.name
  end

  def stage_id
    stageable.is_a?(Annihilation) ? stageable.stages.first.id : super
  end

  def challenge_mode=(value)
    @challenge_mode = stageable&.challengable? ? ActiveRecord::Type::Boolean.new.cast(value) : nil
  end

  def environment=(value)
    @environment = stageable&.has_environments? ? value : nil
  end

  def reset_spec
    self.stage_id = nil
    self.stageable_id = nil
    self.environment = nil
    self.challenge_mode = nil
  end
end
