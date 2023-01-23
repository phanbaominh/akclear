# frozen_string_literal: true

class ApplicationService
  include Dry::Monads[:result, :do]

  def self.call(...)
    new(...).call
  end

  def initialize(*args); end

  private

  def log_info(info)
    Rails.logger.info(info)
  end
end
