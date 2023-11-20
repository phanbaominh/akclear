class UsedOperatorsSession
  class Info
    def self.from_raw(raw)
      params = raw.each_with_index.with_object({}) do |(value, idx), acc|
        acc[PERSISTED_OPERATORS_ATTRIBUTES[idx]] = value
      end
      new(params)
    end

    def initialize(params)
      @params = params.respond_to?(:with_indifferent_access) ? params.with_indifferent_access : params
    end

    def raw
      @raw ||= PERSISTED_OPERATORS_ATTRIBUTES.reduce([]) do |acc, attr|
        acc << @params[attr]
      end
    end

    def ==(other)
      (raw - other.raw).empty?
    end

    def [](key)
      @params[key]
    end
  end

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
    existing = find_by_operator_id(params[:operator_id]).first
    if existing
      existing_info = Info.from_raw(existing['info'])
      params = params.merge(id: existing_info['id'], clear_id: existing_info['clear_id'])
      update(params)
    else
      data << get_info(params)
    end
    params
  end

  def remove(operator_id)
    attrs = find_by_operator_id(operator_id).first
    attrs['_destroy'] = true if attrs
    self
  end

  def update(params)
    _, index = find_by_operator_id(params[:operator_id])
    data[index] = get_info(params) if index
    self
  end

  def to_h
    data
  end

  def find_by_operator_id(operator_id)
    idx = data.find_index do |used_operator|
      Info.from_raw(used_operator['info'])['operator_id'].to_s == operator_id.to_s
    end
    [idx ? data[idx] : nil, idx]
  end

  def get_info(params)
    info = { 'info' => Info.new(params).raw }
    info['id'] = params[:id] if params[:id]
    info
  end
end
