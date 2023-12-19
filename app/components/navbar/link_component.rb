# frozen_string_literal: true

class Navbar::LinkComponent < ApplicationComponent
  renders_one :link

  attr_reader :title, :path, :highlighted

  def post_initialize(path: nil, title: nil, highlighted: nil)
    @title = title
    @path = path
    @highlighted = highlighted
  end

  def highlighted?
    return highlighted unless highlighted.nil?

    current_page?(path)
  end
end
