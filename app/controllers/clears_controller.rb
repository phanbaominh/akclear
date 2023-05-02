# frozen_string_literal: true

class ClearsController < ApplicationController
  include ClearFilterable
  include Pagy::Backend

  def index
    unset_modifying_clear
    use_clear_spec_param
    set_clear_spec
    set_clear_spec_session
    @clear_spec_params = clear_spec_params
    @pagy, @clears = pagy(Clears::Index.(@clear_spec).value!.includes(used_operators: :operator, stage: :stageable))
  end

  def new
    set_modifying_clear
    set_clear_spec
    @clear = @clear_spec
  end

  def create
    @clear = Clear.new((clear_params.presence || clear_spec_session).merge(submitter: Current.user))
    if @clear.save
      delete_clear_spec_session
      redirect_to clears_path
    else
      render 'new', status: :unprocessable_entity
    end
  end
end
