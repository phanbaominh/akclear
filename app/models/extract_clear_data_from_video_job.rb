class ExtractClearDataFromVideoJob < ApplicationRecord
  include AASM
  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3 }

  aasm column: :status, enum: true do
    state :pending, initial: true
    state :processing
    state :completed
    state :failed

    event :process do
      transitions from: :pending, to: :processing
    end

    event :complete do
      transitions from: :processing, to: :completed
    end

    event :fail do
      transitions from: :processing, to: :failed
    end
  end
end
