class ClearPresenter < ApplicationPresenter
  def player_name
    object.channel&.title || I18n.t(:anonymous)
  end
end
