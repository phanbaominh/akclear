# frozen_string_literal: true

class Clears::ReportComponent < ApplicationComponent
  include Turbo::FramesHelper
  attr_reader :clear

  def post_initialize(clear:)
    @clear = clear
  end
end
