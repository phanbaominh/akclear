# frozen_string_literal: true

class ClearsController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @clears = pagy(Clear.all.includes(used_operators: :operator, stage: :stageable))
    @clear_spec_params = clear_spec_params
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

  def clear_spec_params
    return {} if params[:clear].nil?

    params.require(:clear).permit(:stageable, :stage_id, :challenge_mode, operator_ids: [])
  end

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
