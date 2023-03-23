# frozen_string_literal: true

class Clear::Specification
  extend Dry::Initializer

  option :stageable_id, optional: true, type: ::Types::Coercible::Integer
  option :stageable_type, optional: true, type: ::Types::Coercible::String
  option :stage_id, optional: true, type: ::Types::Coercible::Integer
  option :operator_ids, optional: true, default: proc { [] }, type: ::Types::Array.of(Types::Coercible::Integer)

  def stageable
    stageable_type&.constantize&.find_by(id: stageable_id)
  end

  def stage
    Stage.find_by(id: stage_id)
  end
end
