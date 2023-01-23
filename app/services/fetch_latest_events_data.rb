# frozen_string_literal: true

class FetchLatestEventsData < ApplicationService
  SOURCE = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/en_US/gamedata/excel/activity_table.json'
  EVENT_TYPES = %w[MINISTORY SIDESTORY].freeze

  def call
    events_data = yield FetchJson.call(SOURCE)
    events_data = events_data['basicInfo']
    is_first_event = true
    count = 0
    events_data.each do |event_id, event_data|
      # debugger
      next unless valid_event?(event_data)

      name = event_data['name']

      event = Event.create_with(name:).find_or_create_by!(game_id: event_id)
      unless event.previously_new_record?
        is_first_event = false
        next
      end

      log_info("Event #{name} created successfully!")
      count += 1

      mark_as_latest(event) if is_first_event

      is_first_event = false
    rescue StandardError
      log_info("Failed to create event #{name}: #{event.error_message}")
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

  def mark_as_latest(event)
    Event.transaction do
      Event.latest&.update!(latest: false)
      event.update!(latest: true)
    end
    event
  end
end
