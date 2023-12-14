module StageSpecifiable
  extend ActiveSupport::Concern
  attr_writer :stageable_id, :stage_type
  attr_reader :challenge_mode

  STAGE_ATTRIBUTES = %i[stage_id stageable_id stage_type challenge_mode environment].freeze

  included do
    respond_to?(:validates) do
      validates :stage_type, inclusion: { in: Stage::STAGEABLE_TYPES }, allow_blank: true
    end
  end

  def set_stage_attrs_from_params(params) # rubocop:disable Naming/AccessorMethodName
    STAGE_ATTRIBUTES.each { |attr| send("#{attr}=", params[attr]) }
  end

  def environment
    Episode::Environment.new(@environment) if @environment
  end

  def stage
    super if defined?(super)
  end

  def stage_id=(value)
    if defined?(super)
      super
    else
      @stage_id = value
    end
  end

  def stageable
    if @stageable_id
      # causing CACHE HIT in stage_select_component
      GlobalID::Locator.locate(stageable_id)
    else
      stage&.stageable
    end
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
    if stageable.is_a?(Annihilation)
      stageable.stages.first.id
    elsif defined?(super)
      super
    else
      @stage_id
    end
  end

  def stage_ids=(value)
    value = value.compact_blank.map(&:to_i)
    @stage_ids = value
    self.stage_id = value.first
  end

  def stage_ids
    @stage_ids ||= [stage_id]
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
