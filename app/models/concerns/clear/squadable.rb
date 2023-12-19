module Clear::Squadable
  extend ActiveSupport::Concern

  included do
    has_many :used_operators, dependent: :destroy
    accepts_nested_attributes_for :used_operators, allow_destroy: true

    validate :valid_squad
  end

  def valid_squad
    return if squad.valid?

    squad.errors.each do |error|
      errors.import(error)
    end
  end

  def squad
    valid_used_operators = used_operators.reject(&:marked_for_destruction?)
    if @squad
      @squad.used_operators = valid_used_operators
    else
      @squad = Squad.new(used_operators: valid_used_operators)
    end
    @squad
  end
end
