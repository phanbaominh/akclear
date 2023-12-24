# frozen_string_literal: true

class Event < ApplicationRecord
  include Stageable

  belongs_to :original_event, class_name: 'Event', optional: true
  has_one :rerun_event, class_name: 'Event', foreign_key: :original_event_id, dependent: :nullify,
                        inverse_of: :original_event

  validates :original_event, presence: true, if: :rerun_event?

  scope :original, -> { where(original_event_id: nil) }
  scope :selectable, -> { original }
  scope :latest, -> { where(start_time: ..Time.current).where(end_time: Time.current..).order(end_time: :asc) }

  def self.challengable?
    true
  end

  def rerun_event?
    original_event_id.present? || name.include?('Rerun')
  end
end
