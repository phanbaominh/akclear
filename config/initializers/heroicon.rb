# frozen_string_literal: true

Heroicon.configure do |config|
  config.variant = :solid # Options are :solid, :outline and :mini

  ##
  # You can set a default class, which will get applied to every icon with
  # the given variant. To do so, un-comment the line below.
  config.default_class = { solid: 'heroicon', outline: 'heroicon', mini: 'icon-mini' }
end
