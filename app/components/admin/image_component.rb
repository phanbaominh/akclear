class Admin::ImageComponent < ApplicationComponent
  include Turbo::FramesHelper

  def post_initialize(path:, **options)
    @path = path
    @options = options
  end
end
