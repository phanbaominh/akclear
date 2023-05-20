class EpisodePresenter < StageablePresenter
  def index
    object.game_id.split('_').last
  end

  def label
    "#{I18n.t} #{object.index} #{object.name}"
  end

  def type_color
    ''
  end
end
