class AnnihilationPresenter < StageablePresenter
  def banner_image_path
    "https://raw.githubusercontent.com/yuanyan3060/ArknightsGameResource/main/map/#{object.game_id}.png"
  end

  def index
    object.game_id.split('_').last
  end

  def label
    "#{I18n.t(:annihilation)} #{index} - #{object.name}"
  end

  def color(component)
    {
      badge: 'badge-error text-error-content'
    }[component] || 'error'
  end
end
