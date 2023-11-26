module Helpers
  module Turbo
    def wait_for_turbo(timeout = nil)
      return unless has_css?('.turbo-progress-bar', visible: true, wait: 0.25.seconds)

      has_no_css?('.turbo-progress-bar', wait: timeout.presence || 5.seconds)
    end
  end
end
