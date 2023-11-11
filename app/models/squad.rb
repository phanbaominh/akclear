# frozen_string_literal: true

class Squad
  MAX_USED_OPERATORS = 13
  include ActiveModel::Model

  attr_accessor :used_operators

  validates :used_operators, length: { maximum: MAX_USED_OPERATORS }
  validate :no_duplicates

  def no_duplicates
    return if used_operators.pluck('operator_id').map(&:to_i).uniq.size == used_operators.size

    errors.add(:used_operators, :duplicated)
  end

  def used_operators_attributes=(attrs)
    attrs.reject { |attr| attr['_destroy'] }.each { |attr| add(attr) }
  end

  def add(used_operator_params)
    @used_operators ||= []
    p used_operator_params
    used_operator = UsedOperator.new(used_operator_params)
    @used_operators << used_operator
    used_operator.squad = self
    used_operator
  end

  def full?
    used_operators.size >= MAX_USED_OPERATORS
  end

  def operator_ids
    used_operators.pluck('operator_id')
  end
end
