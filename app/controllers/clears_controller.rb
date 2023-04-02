# frozen_string_literal: true

class ClearsController < ApplicationController
  include ClearFilterable
  include Pagy::Backend

  def index
    @clear_spec_params = clear_spec_params
    @pagy, @clears = pagy(Clears::Index.(@clear_spec).value!.includes(used_operators: :operator, stage: :stageable))
  end

  def new
    @clear = Clear.new(clear_params)
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def create
    (@clear = Clear.new(clear_params))
    if @clear.save
      redirect_to @clear
    else
      render 'new', status: :unprocessable_entity
    end
  end

  private

  def clear_params
    return @clear_params if @clear_params
    return nil if action_name != 'create' && params[:clear].nil?

    @clear_params = params
                    .require(:clear)
                    .permit(:name, :link, :stage_id, used_operators_attributes: %i[id operator_id _destroy
                                                                                   need_to_be_destroyed level elite
                                                                                   skill_level skill_mastery skill])
    @clear_params = @clear_params.merge(submitter_id: Current.user.id)
  end
end
