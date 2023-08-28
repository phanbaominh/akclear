class Video
  class InvalidUrl < StandardError; end
  YOUTUBE_REGEX = %r{(?:https?://)?(?:www\.)?(?:youtube\.com|youtu\.be)/(?:watch\?v=)?(.+)}
  def initialize(url)
    @url = url
  end

  def to_url
    url
  end

  def timestamp
    CGI.parse(URI.parse(url).query)['t'].first
  end

  def title
    metadata&.title
  end

  def valid?
    return @valid if defined?(@valid)

    @valid = YOUTUBE_REGEX.match?(@url)
  end

  private

  def metadata
    @metadata ||= Yt::Video.new(url:)
  end

  def url
    raise InvalidUrl unless valid?

    @url
  end
end
