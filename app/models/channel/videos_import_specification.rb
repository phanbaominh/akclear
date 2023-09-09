class Channel::VideosImportSpecification
  def initialize(params)
    @params = params
  end

  def channels
    @channels ||= params[:channel_ids].present? ? Channel.where(id: params[:channel_ids]) : Channel.all
  end

  def satisfy?(video_data)
    stages.blank? || has_specified_stages_code_in_title?(video_data)
  end

  private

  attr_reader :params

  def has_specified_stages_code_in_title?(video_data)
    stages.any? { |stage| video_data.title.include?(stage.code) }
  end

  def stageable
    return if params[:stageable_id].blank?

    @stageable ||= GlobalID::Locator.locate(params[:stageable_id])
  end

  def stages
    @stages ||= stageable&.stages || []
  end
end
