# frozen_string_literal: true

class Clear::Specification
  include SimpleFormable
  extend Dry::Initializer

  option :stageable_id, optional: true, type: ::Types::Params::String
  option :stage_id, optional: true, type: ::Types::Params::Integer
  option :operator_ids, optional: true, default: proc { [] }, type: ::Types::Array.of(Types::Params::Integer)
  option :challenge_mode, optional: true, type: ::Types::Params::Bool

  def stageable
    GlobalID::Locator.locate(stageable_id)
  end

  def stage
    Stage.find_by(id: stage_id)
  end
end
