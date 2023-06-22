# frozen_string_literal: true

class Home::HeroComponent < ApplicationComponent
  attr_reader :stageables, :title, :remote_image

  def initialize(stageables:, title:, remote_image: false)
    @stageables = stageables
    @title = title
    @remote_image = remote_image
  end
end
