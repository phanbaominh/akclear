class Channel::VideosImportSpecification
  MAX_RESULTS_PER_PAGE = 50
  include StageSpecifiable
  attr_reader :channel_ids, :all_channels, :full_pages, :clear_languages

  def initialize(params)
    @params = params
    @all_channels = ActiveRecord::Type::Boolean.new.cast(params[:all_channels])
    @full_pages = ActiveRecord::Type::Boolean.new.cast(params[:full_pages])
    @clear_languages = params[:clear_languages]
    @check_count = 0
    @satisfy_count = 0
    set_stage_attrs_from_params(params)
  end

  def channels
    return @channels if @channels

    @channels = params[:channel_ids].present? ? Channel.where(id: params[:channel_ids]) : Channel.all
    @channels = @channels.have_any_clear_languages(clear_languages) if clear_languages.present?
    @channels
  end

  def satisfy?(video_data)
    @check_count += 1

    return false unless has_arknights_in_title?(video_data)

    @last_check = (stageable.blank? && has_any_stage_code_in_title?(video_data)) || has_specified_stages_code_in_title?(video_data)
    @satisfy_count += 1 if @last_check
    @last_check
  end

  def reset
    @check_count = 0
    @last_check = nil
    @satisfy_count = 0
  end

  def stop?
    first_non_satisfied? || (!full_pages? && check_count >= MAX_RESULTS_PER_PAGE)
  end

  def full_pages?
    full_pages
  end

  def all_channels?
    all_channels
  end

  def persisted?
    false
  end

  def stageable
    @stageable ||= super
  end

  private

  attr_reader :params, :check_count, :last_check, :satisfy_count

  def first_non_satisfied?
    stageable.present? && satisfy_count.positive? && last_check == false
  end

  def has_arknights_in_title?(video_data)
    %w[Arknights アークナイツ 明日方舟].any? { |ak| video_data.title.include?(ak) }
  end

  def has_specified_stages_code_in_title?(video_data)
    stages_codes.any? { |stage_code| video_data.title.include?(stage_code) }
  end
  alias has_any_stage_code_in_title? has_specified_stages_code_in_title?

  def stages_codes
    @stages_codes ||= specified_stages.pluck(:code)
  end
end
