class Channels::AvatarComponent < ApplicationComponent
  attr_reader :thumbnail_url, :size_class

  def post_initialize(thumbnail_url:, size_class: 'w-20 h-20')
    @thumbnail_url = thumbnail_url
    @size_class = size_class
  end
end
