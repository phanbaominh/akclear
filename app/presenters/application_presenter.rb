# frozen_string_literal: true

class ApplicationPresenter
  include Rails.application.routes.url_helpers
  attr_reader :object

  def initialize(object)
    @object = object
  end
end
