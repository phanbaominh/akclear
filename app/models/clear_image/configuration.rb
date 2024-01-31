class ClearImage::Configuration
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :word_in_line_first_pass_confidence_threshold, :integer, default: 70
  attribute :word_in_line_second_pass_confidence_threshold, :integer, default: 70
  attribute :max_largest_card_dist_to_smallest_dist_ratio_to_guess_dist_between_card, :float, default: 1.2
  attribute :max_character_distance_to_width_ratio_to_be_near, :float, default: 1.5

  class << self
    def for_current_thread=(options)
      options ||= { en: { word_in_line_second_pass_confidence_threshold: 30 } }
      global_options = options[:global] || {}
      Thread.current[:clear_image_configuration] =
        ClearImage::Extracting::Reader::LOCALE_TO_TESSERACT_LANG.keys.map.with_object({}) do |language, lang_to_config|
          lang_to_config[language] = new(global_options.merge(options[language] || {}))
        end
    end

    def instance
      Thread.current[:clear_image_configuration]
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
