# frozen_string_literal: true

class Admin::ExtractClearResultImportsController < ApplicationController
  def create
    authorize! :import, ExtractClearDataFromVideoJob

    if ExtractClearResultImporter.new(importer_params).import_later
      respond_to do |format|
        format.html do
          redirect_to admin_clear_jobs_path, notice: t('.success')
        end
        format.turbo_stream do
          flash_stream(status: :created, type: 'notice', msg: t('.success'))
        end
      end
    else
      respond_to do |format|
        format.html do
          redirect_to admin_clear_jobs_path, alert: t('.failed')
        end
        format.turbo_stream do
          flash_stream(status: :unprocessable_entity, type: 'alert', msg: t('.failed'))
        end
      end
    end
  end

  private

  def importer_params
    params.require(:extract_clear_result_importer).permit(:file)
  end
end
