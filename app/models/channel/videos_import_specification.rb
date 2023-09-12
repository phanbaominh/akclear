class Channel::VideosImportSpecification
  MAX_RESULTS_PER_PAGE = 50
  include StageSpecifiable
  attr_reader :channel_ids, :all_channels, :full_pages

  def initialize(params)
    @params = params
    @all_channels = ActiveRecord::Type::Boolean.new.cast(params[:all_channels])
    @full_pages = ActiveRecord::Type::Boolean.new.cast(params[:full_pages])
    @check_count = 0
  end

  def channels
    @channels ||= params[:channel_ids].present? ? Channel.where(id: params[:channel_ids]) : Channel.all
  end

  def satisfy?(video_data)
    @check_count += 1
    (stageable.blank? && has_any_stage_code_in_title?(video_data)) || has_specified_stages_code_in_title?(video_data)
  end

  def reset
    @check_count = 0
  end

  def stop?
    !full_pages? && check_count >= MAX_RESULTS_PER_PAGE
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

  private

  attr_reader :params, :check_count

  def has_specified_stages_code_in_title?(video_data)
    stages_codes.any? { |stage_code| video_data.title.include?(stage_code) }
  end
  alias has_any_stage_code_in_title? has_specified_stages_code_in_title?

  def stageable
    return if params[:stageable_id].blank?

    @stageable ||= GlobalID::Locator.locate(params[:stageable_id])
  end

  def stages_codes
    @stages_codes ||= (stageable&.stages || Stage.all).pluck(:code)
  end
end
