# frozen_string_literal: true

class ClearsController < ApplicationController
  skip_before_action :authenticate!, only: %i[index show]
  load_and_authorize_resource except: :edit

  include ClearFilterable
  include Pagy::Backend

  def index
    unset_modifying_clear
    use_clear_spec_param
    set_clear_spec
    set_clear_spec_session_from_params
    @pagy, @clears = pagy(
      Clears::Index.(@clear_spec).value!.includes(:channel, :verification, :likers, used_operators: :operator,
                                                                                    stage: :stageable).order(created_at: :desc)
    )
    Operator.build_translations_cache(Operator.from_clear_ids(@clears.map(&:id)))
  end

  def show
    @clear.preload_operators
  end

  def new
    set_modifying_clear
    delete_clear_spec_session_of_existing_clear
    set_clear_spec
    @clear = @clear_spec
  end

  def edit
    set_modifying_clear
    init_clear_spec_session_from_existing_clear
    set_clear_spec
    @clear = @clear_spec.preload_operators
    authorize! :edit, @clear
    render 'new'
  end

  def create
    @clear.submitter = Current.user
    if @clear.save
      @clear.duplicate_for_stage_ids(@clear.stage_ids)
      delete_clear_spec_session
      redirect_to @clear
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def update
    if @clear.update(clear_params)
      delete_clear_spec_session
      redirect_to @clear
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def used_session_keys
    [clear_spec_session_key]
  end
end
