# frozen_string_literal: true

# should probably used locally

class Admin::ExtractClearResultExportsController < ApplicationController
  include ActionController::Live

  # use show for GET request as POST request not support accept type text/plain
  def show
    authorize! :import, ExtractClearDataFromVideoJob

    send_stream(filename: 'extract_clear_result.txt', type: 'text/plain') do |stream|
      ExtractClearResultExporter.new.export(stream)
    end
  end
end
