class EpisodePresenter < StageablePresenter
  def index
    object.game_id.split('_').last
  end

  def label
    "#{I18n.t(:episode)} #{object.index} - #{object.name}"
  end

  def color(component)
    {
      badge: 'badge-info text-info-content'
    }[component] || 'info'
  end
end
