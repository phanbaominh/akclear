# frozen_string_literal: true

class ClearsController < ApplicationController
  skip_before_action :authenticate!, only: %i[index show]
  include ClearFilterable
  include Pagy::Backend

  def index
    unset_modifying_clear
    use_clear_spec_param
    set_clear_spec
    set_clear_spec_session
    @pagy, @clears = pagy(
      Clears::Index.(@clear_spec).value!.includes(used_operators: :operator,
                                                                      stage: :stageable).order(created_at: :desc))
  end

  def show
    @clear = Clear.find(params[:id])
  end

  def new
    set_modifying_clear
    set_clear_spec
    @clear = @clear_spec
  end

  def create
    @clear = Clear.new(clear_params.presence.merge(submitter: Current.user))
    if @clear.save
      @clear.duplicate_for_stage_ids(@clear.stage_ids)
      delete_clear_spec_session
      redirect_to @clear
    else
      render 'new', status: :unprocessable_entity
    end
  end
end
