# frozen_string_literal: true

class Navbar::LinkComponent < ApplicationComponent
  renders_one :link

  attr_reader :title, :path, :highlighted

  def post_initialize(path: nil, title: nil, highlighted: nil, border_left: false)
    @title = title
    @path = path
    @highlighted = highlighted
    @border_left = border_left
  end

  def highlighted?
    return highlighted unless highlighted.nil?

    current_page?(path)
  end

  def border_left?
    @border_left
  end

  def border_class
    return unless highlighted?

    border_left? ? border_left_class : responsive_border_class
  end

  def border_left_class
    'border-l-4 border-l-primary'
  end

  def responsive_border_class
    'border-l-4 border-l-primary lg:border-l-0 lg:border-b-4 lg:!border-b-primary '
  end
end
