module TurboFlashable
  extend ActiveSupport::Concern

  def flash_stream(status:, type:, msg:)
    render turbo_stream: turbo_stream.append(
      'flash', partial: 'shared/flash_message',
               locals: { name: type, msg: }
    ), status:
  end
end
