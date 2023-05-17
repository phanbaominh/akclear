class AnnihilationPresenter < StageablePresenter
  def banner_image_path
    "https://raw.githubusercontent.com/yuanyan3060/ArknightsGameResource/main/map/#{object.game_id}.png"
  end
end
