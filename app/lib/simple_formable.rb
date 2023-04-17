# frozen_string_literal: true

module SimpleFormable
  extend ActiveSupport::Concern
  included do
    extend ActiveModel::Naming
  end

  attr_accessor :id, :name

  def to_model
    self
  end

  def to_key
    id
  end

  def persisted?
    false
  end
end
