# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  def initialize(class: '', id: '', **options)
    @class = binding.local_variable_get(:class)
    @id = id
    post_initialize(**options)
  end

  def post_initialize(**options); end
end
