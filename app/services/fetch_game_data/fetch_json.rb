# frozen_string_literal: true

module FetchGameData
  class FetchJson < ApplicationService
    def initialize(source)
      @source = source
    end

    def call
      file = URI.parse(source).open
      raw_data = file.read
      data = JSON.parse(raw_data)

      Success(data)
    end

    def log_service
      nil
    end

    private

    attr_reader :source
  end
end
