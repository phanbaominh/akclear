# frozen_string_literal: true

class ApplicationService
  extend Dry::Initializer
  include Dry::Monads[:result, :do]

  def self.call(...)
    new(...).call
  end

  def call
    raise NotImplementedError
  end

  private

  def log_info(info)
    Rails.logger.info(info)
  end
end
