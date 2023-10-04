class Video
  class InvalidUrl < StandardError; end
  YOUTUBE_REGEX = %r{(?:https?://)?(?:www\.)?(?:youtube\.com|youtu\.be)/(?:watch\?v=)?(.+)}
  ALLOWED_YOUTUBE_PARAM_KEYS = %w[v t].freeze

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

  def stage_id
    @stage_id ||= stages_ids_and_codes.find { |(_id, code)| title&.include?(code) }&.first
  end

  def valid?
    return @valid if defined?(@valid)

    @valid = YOUTUBE_REGEX.match?(@url)
    # make sure that @valid has value first or it will lead to infinite recursion when querying url
    @valid &&= params_contains_only_allowed_keys?
  end

  def ==(other)
    self.class == other.class && to_url == other.to_url
  end

  def embed_link
    self.class.normalized_url(video_id).gsub('watch?v=', 'embed/')
  end

  private

  def stages_ids_and_codes
    @stages_ids_and_codes ||= Stage.all.non_challenge_mode.pluck(:id, :code)
  end

  def params_contains_only_allowed_keys?
    params.blank? || params.keys.all? { |key| ALLOWED_YOUTUBE_PARAM_KEYS.include?(key) }
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

  def url
    raise InvalidUrl unless valid?

    @url
  end
end
