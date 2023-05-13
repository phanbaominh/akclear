# frozen_string_literal: true

module FetchGameData
  class FetchLatestEventsData < ApplicationService
    SOURCE = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/en_US/gamedata/excel/activity_table.json'
    EVENT_TYPES = %w[MINISTORY SIDESTORY].freeze

    def call
      events_data = yield FetchJson.call(SOURCE)
      events_data = events_data['basicInfo']
      count = 0
      events_data.each do |event_id, event_data|
        next unless valid_event?(event_data)

        name = event_data['name']

        event = Event.find_or_initialize_by(game_id: event_id)
        event.update!(name:, end_time: Time.zone.at(event_data['endTime']))
        if event.previously_new_record?
          log_info("Event #{event_id} created successfully!")
          count += 1
        else
          log_info("Event #{event_id} updated successfully!")
        end

      rescue StandardError => e
        log_info("Failed to create/update event #{name}: #{e.message}")
      end
      log_info("Fetching completed! #{count} new events were created!")

      Success()
    end

    private

    def valid_event?(event_data)
      return false unless sidestory_or_ministory_event?(event_data)

      return false if rerun_event?(event_data)

      true
    end

    def sidestory_or_ministory_event?(event_data)
      EVENT_TYPES.include?(event_data['displayType'])
    end

    def rerun_event?(event_data)
      event_data['isReplicate']
    end
  end
end
