# frozen_string_literal: true

class ClearImage
  include Extractable
  include TmpFileStorable

  attr_reader :used_language

  def initialize(image_path, configuration_options = {}, log_data_path: 'tmp/clear_image_test/',
                 possible_languages: Channel.clear_languages)
    @image_path = image_path
    @possible_languages = possible_languages
    Logger.dir_path_for_current_thread = log_data_path.to_s
    Configuration.for_current_thread = configuration_options
    return unless possible_languages.present? && possible_languages.size == 1

    Extracting::Reader.language = possible_languages.first.to_sym
  end

  def used_operators_data
    @used_operators_data ||= extract
  end

  private

  attr_reader :image_path, :operator_name_only, :possible_languages

  def image
    @image ||= Magick::ImageList.new(image_path.to_s)
  end
end
