class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :ability

  delegate :user, to: :session, allow_nil: true
end
