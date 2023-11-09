class UsedOperatorsSession
  PERSISTED_OPERATORS_ATTRIBUTES = %i[operator_id clear_id level elite skill_level skill_mastery skill id].freeze
  attr_accessor :data

  def initialize(data)
    @data = data
  end

  def init_from_clear(clear)
    clear.used_operators.each do |used_operator|
      used_operator_params = used_operator.attributes.symbolize_keys.slice(
        *PERSISTED_OPERATORS_ATTRIBUTES
      )
      add(used_operator_params)
    end
    self
  end

  def add(params)
    max_index = (data.keys.map(&:to_i).max || 0) + 1
    data[max_index.to_s] = params
    self
  end

  def remove(operator_id)
    data&.delete_if do |_key, used_operator|
      used_operator['operator_id'] == operator_id
    end
    self
  end

  def update(params)
    index = data&.find do |_key, used_operator|
      used_operator['operator_id'].to_s == params[:operator_id]
    end&.first
    data[index] = params if index
    self
  end

  def to_h
    data
  end
end
