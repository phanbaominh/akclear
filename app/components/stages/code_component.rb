# frozen_string_literal: true

class Stages::CodeComponent < ApplicationComponent
  renders_one :code
  attr_reader :stage

  def post_initialize(stage:)
    @stage = stage
  end
end
