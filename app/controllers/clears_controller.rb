# frozen_string_literal: true

class ClearsController < ApplicationController
  include ClearFilterable
  include Pagy::Backend

  def index
    set_clear_spec_session
    @clear_spec_params = clear_spec_params
    @pagy, @clears = pagy(Clears::Index.(@clear_spec).value!.includes(used_operators: :operator, stage: :stageable))
  end

  def new
    @clear = Clear.new(clear_params)
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

    params[:clear][:used_operators_attributes] ||= {}
    @clear_params =
      params
      .require(:clear)
      .permit(
        :name,
        :link,
        :stage_id,
        operator_ids: [],
        used_operators_attributes: %i[
          id operator_id _destroy need_to_be_destroyed level elite skill_level skill_mastery skill
        ]
      )

    update_used_operators_param!(@clear_params.delete(:operator_ids) || [], @clear_params[:used_operators_attributes])
    @clear_params = @clear_params.merge(submitter_id: Current.user.id)
  end

  def update_used_operators_param!(selected_operator_ids, used_operators_param)
    current_used_operator_ids = used_operators_param.values.map do |used_operator|
      used_operator[:operator_id]
    end

    used_operators_count = current_used_operator_ids.size
    deleted_operator_ids = current_used_operator_ids - selected_operator_ids
    new_operator_ids = selected_operator_ids - current_used_operator_ids

    used_operators_param.reject! do |_index, used_operator|
      deleted_operator_ids.include?(used_operator[:operator_id])
    end
    new_operator_ids.each do |operator_id|
      @clear_params[:used_operators_attributes].merge!(used_operators_count => { operator_id: })
    end
  end
end
