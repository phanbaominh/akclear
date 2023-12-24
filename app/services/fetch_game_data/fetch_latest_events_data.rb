# frozen_string_literal: true

module FetchGameData
  class FetchLatestEventsData < ApplicationService
    SOURCE = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/main/en_US/gamedata/excel/activity_table.json'
    EVENT_TYPES = %w[MINISTORY SIDESTORY].freeze
    EVENT_ID_TYPES = %w[side mini].freeze

    def initialize(json: false)
      @json = json
    end

    def call
      events_data = yield FetchJson.call(SOURCE)
      events_data = events_data['basicInfo']
      events = events_data.filter_map do |event_id, event_data|
        next unless valid_event?(event_data)

        store_event(event_id, event_data)
      rescue StandardError => e
        log_info("Failed to create/update event #{event_id}: #{e.message}")
      end
      fetch_logger.log_summary

      Success(events)
    end

    private

    def fetch_logger
      @fetch_logger ||= FetchLogger.new(Event.name)
    end

    def json?
      @json
    end

    def store_event(event_id, event_data)
      name = event_data['name']

      if json?
        {
          name:,
          game_id: event_id
        }
      else

        event = Event.find_or_initialize_by(game_id: event_id)
        end_time = Time.zone.at(event_data['endTime'])
        start_time = Time.zone.at(event_data['startTime'])

        original_name = name.split('-').first.strip

        original_event = (Event.find_by(name: original_name) if rerun_event?(event_data))
        event.update!(name:, end_time:, original_event:, start_time:)
        fetch_logger.log_write(event, event_id)
        event
      end
    end

    def valid_event?(event_data)
      return false unless sidestory_or_ministory_event?(event_data)

      true
    end

    def sidestory_or_ministory_event?(event_data)
      EVENT_TYPES.include?(event_data['displayType']) ||
        EVENT_ID_TYPES.any? { |event_type| event_data['id'].include?(event_type) }
    end

    def rerun_event?(event_data)
      event_data['isReplicate']
    end
  end
end
