# frozen_string_literal: true

class ApplicationPresenter
  attr_reader :object

  def initialize(object)
    @object = object
  end
end
