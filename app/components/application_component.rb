# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  def initialize(class: '', id: '', **options)
    @class = binding.local_variable_get(:class)
    @id = id
    post_initialize(**options)
  end

  def presenter_object
    nil
  end

  def presenter
    @presenter ||= "#{presenter_object.class.name}Presenter".constantize.new(presenter_object)
  end

  def post_initialize(**options); end

  def stimuluses(**options)
    include_controller = options.delete(:include_controller)
    include_controller = false if include_controller.nil?
    stimulus_data = options.map do |(controller, attributes)|
      include_controller ? stimulus(controller, **attributes) : stimulus_attrs(controller, **attributes)
    end

    stimulus_data.reduce do |acc, s|
      acc.merge(s) { |key, oldval, newval| %i[controller action].include?(key) ? "#{oldval} #{newval}" : newval }
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

  def time_string(time)
    "#{time_ago_in_words(time)} #{I18n.t(:ago)}"
  end

  def by_string(performer_name)
    "#{I18n.t(:by)} #{performer_name}"
  end

  def current_user
    Current.user
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
