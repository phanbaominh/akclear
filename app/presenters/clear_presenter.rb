class ClearPresenter < ApplicationPresenter
  def player_name
    object.channel&.name || I18n.t(:anonymous)
  end
end
