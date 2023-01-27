# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  def initialize(classes: '', id: '')
    @classes = classes
    @id = id
  end
end
