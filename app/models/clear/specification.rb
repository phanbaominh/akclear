# frozen_string_literal: true

class Clear::Specification
  include SimpleFormable
  extend Dry::Initializer

  option :stageable_id, optional: true, type: ::Types::Params::String
  option :stage_id, optional: true, type: ::Types::Params::Integer
  option :operator_id, optional: true, type: ::Types::Params::Integer
  option :challenge_mode, optional: true, type: ::Types::Params::Bool
  option :used_operators_attributes, optional: true, default: -> { {} }

  def used_operators
    @used_operators ||= used_operators_attributes.values.map { |attrs| UsedOperator.new(attrs) }
  end

  def stageable
    GlobalID::Locator.locate(stageable_id)
  end

  def stage
    Stage.find_by(id: stage_id)
  end

  def used_operators_attributes=
    nil
  end
end
