class ImportVideosJob < ApplicationJob
  queue_as :system

  def perform(spec_params)
    spec = Channel::VideosImportSpecification.new(spec_params.transform_keys(&:to_sym))
    Channel.import_videos(spec)
    # Do something later
  end
end
