class ImportVideosJob < ApplicationJob
  queue_as :system

  def perform(*args)
    # Do something later
  end
end
