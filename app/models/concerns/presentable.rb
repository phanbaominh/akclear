# frozen_string_literal: true

module Presentable
  extend ActiveSupport::Concern

  def method_missing(method, ...)
    # use & to prevent nil as nil is being able to respond_to? methods
    super unless presenter&.respond_to?(method) # rubocop:disable Lint/RedundantSafeNavigation

    presenter.send(method, ...)
  end

  def presenter
    @presenter ||= to_presenter
  end

  def to_presenter
    "#{self.class}Presenter".constantize.new(self) if Object.const_defined?("#{self.class}Presenter")
  end

  def respond_to_missing?(method, include_private = false)
    # use & to prevent nil as nil is being able to respond_to? methods
    presenter&.respond_to?(method) || super # rubocop:disable Lint/RedundantSafeNavigation
  end
end
