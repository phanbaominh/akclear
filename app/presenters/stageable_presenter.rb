# frozen_string_literal: true

class StageablePresenter < ApplicationPresenter
  def filter_link
    clears_path(clear: { stageable_id: object.to_global_id.to_s })
  end

  def banner_image_path
    "images/banners/#{object.game_id}.jpg"
  end

  def label
    object.name
  end

  def type_label
    object.class.to_s.titleize
  end

  def type_color
    raise NotImplementedError
  end
end
