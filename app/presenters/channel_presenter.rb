class ChannelPresenter < ApplicationPresenter
  def clear_count_text
    "#{object[:clear_count] || object.clears.count} #{I18n.t('.clears.item')}"
  end

  def url
    "https://www.youtube.com/channel/#{object.external_id}"
  end
end
