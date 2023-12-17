class Video
  class InvalidUrl < StandardError; end
  YOUTUBE_REGEX = %r{(?:https?://)?(?:www\.)?(?:youtube\.com|youtu\.be)/(?:watch\?v=)?(.+)}
  ALLOWED_YOUTUBE_PARAM_KEYS = %w[v t].freeze

  include ActiveModel::Validations

  validates :url, presence: true, format: { with: YOUTUBE_REGEX }
  validate :params_contains_only_allowed_keys

  attr_writer :metadata

  def self.from_id(video_id)
    new(normalized_url(video_id))
  end

  def self.normalized_url(video_id)
    "https://youtube.com/watch?v=#{video_id}"
  end

  def initialize(url)
    @url = url
  end

  def to_url(normalized: false)
    normalized ? self.class.normalized_url(video_id) : url
  end

  def timestamp
    params['t'].first
  end

  def title
    metadata&.title
  end

  def channel_external_id
    metadata&.channel_id
  end

  def stage_id
    @stage_id ||= stages_ids_and_codes.find { |(_id, code)| title&.include?(code) }&.first
  end

  def ==(other)
    self.class == other.class && to_url == other.to_url
  end

  def embed_link
    self.class.normalized_url(video_id).gsub('watch?v=', 'embed/')
  end

  private

  attr_reader :url

  def stages_ids_and_codes
    # sort by last so that CW-10 will be checked before CW-1
    @stages_ids_and_codes ||= Stage.all.non_challenge_mode.pluck(:id, :code).sort_by(&:last).reverse
  end

  def params_contains_only_allowed_keys
    return if errors[:url].present?

    return if params.blank? || (params.keys - ALLOWED_YOUTUBE_PARAM_KEYS).empty?

    errors.add(:url, :invalid)
  end

  def video_id
    params['v']&.first || uri.path.slice(1..-1)
  end

  def uri
    @uri ||= URI.parse(url)
  end

  def params
    @params ||= (query_string = uri.query) ? CGI.parse(query_string) : {}
  end

  def metadata
    @metadata ||= Yt::Video.new(url:)
  end
end
