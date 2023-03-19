# frozen_string_literal: true

class ClearsController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @clears = pagy(Clear.all.includes(used_operators: :operator, stage: :stageable))
    @stageable = stageable
    @searched_clear = Clear.new(clear_params.except(:stageable))
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

  def stageable
    return if stageable_params.blank?

    stageable_id, stageable_type = JSON.parse(stageable_params)
    stageable_type&.constantize&.find_by(id: stageable_id)
  end

  def stageable_params
    clear_params[:stageable]
  end

  def clear_params
    return @clear_params if @clear_params
    return nil if action_name != 'create' && params[:clear].nil?

    p 'HERE'

    @clear_params = params
                    .require(:clear)
                    .permit(:name, :link, :stage_id, :stageable, used_operators_attributes: %i[id operator_id _destroy
                                                                                               need_to_be_destroyed level elite
                                                                                               skill_level skill_mastery skill])
    @clear_params = @clear_params.merge(submitter_id: Current.user.id)
  end
end
