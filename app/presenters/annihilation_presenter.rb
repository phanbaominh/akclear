class AnnihilationPresenter < StageablePresenter
  def banner_image_path
    "https://raw.githubusercontent.com/yuanyan3060/ArknightsGameResource/main/map/#{object.game_id}.png"
  end

  def index
    object.game_id.split('_').last
  end

  def label
    "#{object.index} #{object.name}"
  end

  def type_color
    '-error'
  end
end
