# frozen_string_literal: true

module Youtubeable
  extend ActiveSupport::Concern

  def link_attribute
    :link
  end

  def embed_link
    send(link_attribute).gsub(/watch\?v=/, 'embed/')
  end
end
