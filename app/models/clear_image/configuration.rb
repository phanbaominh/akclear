# frozen_string_literal: true

class ClearImage::Configuration
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :word_in_line_first_pass_confidence_threshold, :integer, default: 70
  attribute :word_in_line_second_pass_confidence_threshold, :integer, default: 70
  attribute :max_largest_card_dist_to_smallest_dist_ratio_to_guess_dist_between_card, :float, default: 1.2
  attribute :max_character_distance_to_width_ratio_to_be_near, :float, default: 1.5
  attribute :first_pass_detected_name_similarity_threshold, :float, default: 0.8
  attribute :second_pass_detected_name_similarity_threshold, :float, default: 0.7
  attribute :operator_name_only, :boolean, default: false

  attr_accessor :language

  DEFAULTS = {
    en: {
      word_in_line_first_pass_confidence_threshold: 40,
      word_in_line_second_pass_confidence_threshold: 30
    },
    'zh-CN': {
      word_in_line_first_pass_confidence_threshold: 40,
      word_in_line_second_pass_confidence_threshold: 30,
      first_pass_detected_name_similarity_threshold: 0.7,
      second_pass_detected_name_similarity_threshold: 0.66
    }
  }.freeze

  def initialize(attributes = {})
    super
    self.language = attributes[:language]
    apply_language_specific_defaults
  end

  def apply_language_specific_defaults
    return if language.blank?

    DEFAULTS[language.to_sym]&.each do |key, value|
      send("#{key}=", value)
    end
  end

  class << self
    def for_current_thread=(options = {})
      options = options.with_indifferent_access
      global_options = options[:global] || {}
      Thread.current[:clear_image_configuration] =
        ClearImage::Extracting::Reader::LOCALE_TO_TESSERACT_LANG.keys.map.with_object({}) do |language, lang_to_config|
          lang_to_config[language] = new(global_options.merge(options[language] || { language: }))
        end
    end

    def instance
      Thread.current[:clear_image_configuration]
    end

    def used_instance
      instance[ClearImage::Extracting::Reader.language]
    end

    def method_missing(method, *args)
      super unless instance.present? && instance.values.first.respond_to?(method)

      instance[ClearImage::Extracting::Reader.language].send(method)
    end

    def respond_to_missing?(method, include_private = false)
      (instance && instance.values.first.respond_to?(method)) || super
    end
  end
end
