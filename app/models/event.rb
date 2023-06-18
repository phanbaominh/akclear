# frozen_string_literal: true

class Event < ApplicationRecord
  include Stageable

  belongs_to :original_event, class_name: 'Event', optional: true
  has_one :rerun_event, class_name: 'Event', foreign_key: :original_event_id, dependent: :nullify,
                        inverse_of: :original_event
  def rerun_event?
    original_event_id.present?
  end
end
