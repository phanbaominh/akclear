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
      Clears::Index.(@clear_spec).value!
      .includes(:channel, :verification, :likes, stage: :stageable, used_operators: :operator).order(created_at: :desc)
    )
    Operator.build_translations_cache(Operator.from_clear_ids(@clears.map(&:id)))
  end

  def show
    @clear.preload_operators
  end

  def new
    set_modifying_clear
    delete_clear_spec_session_of_existing_clear
    if params[:use_squad_clear_id]
      @clear = Clear.new
      @clear.used_operators = Clear.find(params[:use_squad_clear_id]).duplicate_squad
      used_operators_session.init_from_clear(@clear)
    else
      set_clear_spec
      @clear = @clear_spec
    end
    return if @clear.used_operators.blank?

    Operator.build_translations_cache(Operator.where(id: @clear.used_operators.map(&:operator_id)))
  end

  def edit
    set_modifying_clear
    init_clear_spec_session_from_existing_clear
    @clear = clear_from_id.preload_operators(with_verification: true)
    @clear.assign_attributes(clear_spec_attributes)
    authorize! :edit, @clear
    render 'new'
  end

  def create
    @clear.submitter = Current.user
    @clear.job_id = nil unless can?(:create, ExtractClearDataFromVideoJob)
    # only allow admin to prevent possible youtube API spam/redundant API calls
    @clear.trigger_assign_channel = can?(:create, Channel)
    if @clear.save
      duplicated_clears = @clear.duplicate_for_stage_ids(@clear.stage_ids)
      delete_clear_spec_session
      redirect_to @clear, notice: t('.success', count: duplicated_clears.count(&:persisted?) + 1)
    else
      flash.now[:error] = @clear.errors.first.full_message
      render 'new', status: :unprocessable_entity
    end
  end

  def update
    # TODO: reset like count when updated|rejected? | not allowed liking when not verified yet?
    if @clear.update(clear_params.except(:link))
      delete_clear_spec_session
      redirect_to @clear, notice: t('.success')
    else
      flash.now[:error] = @clear.errors.first.full_message
      render 'new', status: :unprocessable_entity
    end
  end

  def used_session_keys
    [clear_spec_session_key]
  end
end
