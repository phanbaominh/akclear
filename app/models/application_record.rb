class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def method_missing(method, ...)
    super unless presenter.respond_to?(method)

    presenter.send(method, ...)
  end

  def presenter
    @presenter ||= to_presenter
  end

  def to_presenter
    "#{self.class}Presenter".constantize.new(self) if Object.const_defined?("#{self.class}Presenter")
  end

  def respond_to_missing?(method, include_private = false)
    presenter.respond_to?(method) || super
  end
end
