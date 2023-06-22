# frozen_string_literal: true

class ApplicationService
  extend Dry::Initializer
  include Dry::Monads[:result, :do]

  def self.call(...)
    service = new(...)
    service.log_service
    service.call
  end

  def call
    raise NotImplementedError
  end

  def log_service
    log_info("===#{self.class.name.underscore.humanize}===") if self.class.name.include?('FetchGameData')
  end

  private

  def log_info(info)
    Rails.logger.info(info)
  end

  def log_debug(info)
    Rails.logger.debug(info)
  end
end
