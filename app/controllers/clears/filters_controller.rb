# frozen_string_literal: true

class Clears::FiltersController < ApplicationController
  def index
    @clear_spec = Clear::Specification.new(**(clear_spec_params.to_hash.symbolize_keys || {}))
  end

  private

  def clear_spec_params
    return {} if params[:clear].nil?

    clear_spec_params = params.require(:clear).permit(:stageable, :stage_id, operator_ids: [])
    stageable_id, stageable_type = JSON.parse(clear_spec_params[:stageable])
    clear_spec_params[:operator_ids]
    clear_spec_params.merge(stageable_type:, stageable_id:)
  end
end
