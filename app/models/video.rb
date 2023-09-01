class Video
  class InvalidUrl < StandardError; end
  YOUTUBE_REGEX = %r{(?:https?://)?(?:www\.)?(?:youtube\.com|youtu\.be)/(?:watch\?v=)?(.+)}
  def initialize(url)
    @url = url
  end

  def to_url(normalized: false)
    normalized ? normalized_url : url
  end

  def timestamp
    params['t'].first
  end

  def title
    metadata&.title
  end

  def valid?
    return @valid if defined?(@valid)

    @valid = YOUTUBE_REGEX.match?(@url)
  end

  def ==(other)
    self.class == other.class && to_url == other.to_url
  end

  private

  def video_id
    params['v']&.first || uri.path.slice(1..-1)
  end

  def uri
    @uri ||= URI.parse(url)
  end

  def normalized_url
    "https://youtube.com/watch?v=#{video_id}"
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
