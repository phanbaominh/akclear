# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  def initialize(classes: '', id: '', **options)
    @classes = classes
    @id = id
    post_initialize(**options)
  end

  def post_initialize(**options); end
end
