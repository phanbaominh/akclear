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
    existing = data.find { |used_operator| used_operator['operator_id'].to_s == params[:operator_id] }
    if existing
      params = params.merge(id: existing['id'], clear_id: existing['clear_id'])
      update(params)
    else
      data << params
    end
    params
  end

  def remove(operator_id)
    attrs = data.find do |used_operator|
      used_operator['operator_id'].to_s == operator_id
    end
    attrs['_destroy'] = true if attrs
    self
  end

  def update(params)
    index = data.find_index do |used_operator|
      used_operator['operator_id'].to_s == params[:operator_id]
    end
    data[index] = params if index
    self
  end

  def to_h
    data
  end
end
