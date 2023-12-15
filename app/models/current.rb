class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :user_agent, :ip_address
  attribute :ability

  delegate :user, to: :session, allow_nil: true
end
