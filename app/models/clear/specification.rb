# frozen_string_literal: true

class Clear::Specification
  extend Dry::Initializer

  option :stageable_id, optional: true, type: ::Types::Params::Integer
  option :stageable_type, optional: true, type: Stage::STAGEABLE_TYPES
  option :stage_id, optional: true, type: ::Types::Params::Integer
  option :operator_ids, optional: true, default: proc { [] }, type: ::Types::Array.of(Types::Params::Integer)
  option :challenge_mode, optional: true, type: ::Types::Params::Bool

  def stageable
    stageable_type&.constantize&.find_by(id: stageable_id)
  end

  def stage
    Stage.find_by(id: stage_id)
  end

  def challenge_mode?
    challenge_mode
  end
end
