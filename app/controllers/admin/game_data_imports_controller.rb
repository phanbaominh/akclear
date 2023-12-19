# frozen_string_literal: true

class Admin::GameDataImportsController < ApplicationController
  authorize_resource class: false

  def create
    if ImportGameDataJob.perform_later
      render turbo_stream: turbo_stream.append(
        'flash', partial: 'shared/flash_message',
                 locals: { name: 'notice', msg: t('.success') }
      ), status: :created
    else
      render turbo_stream: turbo_stream.append(
        'flash', partial: 'shared/flash_message',
                 locals: { name: 'alert', msg: t('.failed') }
      ), status: :unprocessable_entity
    end
  end
end
