module StimulusHelper
  def stimuluses(**options)
    stimulus_data = options.map do |(controller, attributes)|
      include_controller = attributes.delete(:include_controller)
      include_controller ? stimulus(controller, **attributes) : stimulus_attrs(controller, **attributes)
    end

    stimulus_data.reduce do |acc, s|
      acc.merge(s) { |key, oldval, newval| %i[controller action].include?(key) ? [oldval, newval].compact.join(' ') : newval }
    end
  end

  def stimulus(controller, **attributes)
    { controller: controller.to_s.dasherize, **stimulus_attrs(controller, **attributes) }
  end

  def stimulus_attrs(controller, **attributes)
    stimulus_controller = controller.to_s.dasherize

    action_data_attribute = attributes.delete(:actions)&.map do |event, function|
      "#{event}->#{stimulus_controller}##{function.camelize(:lower)}"
    end&.join(' ').presence

    { action: action_data_attribute, **stimulus_data_attributes(controller, attributes) }
  end

  private

  def stimulus_data_attributes(controller, attributes)
    data_attributes = {}
    stimulus_data_attributes_mapping.each do |attribute_type, suffix|
      attributes[attribute_type]&.transform_keys! { |key| :"#{controller}_#{key}_#{suffix}" }
      data_attributes.merge!(attributes[attribute_type] || {})
    end
    data_attributes[:"#{controller}_target"] = attributes[:target] if attributes[:target]
    data_attributes
  end

  def stimulus_data_attributes_mapping
    {
      values: 'value',
      outlets: 'outlet',
      classes: 'class',
      params: 'param'
    }
  end
end
