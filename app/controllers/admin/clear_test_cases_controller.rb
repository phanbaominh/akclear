# frozen_string_literal: true

class Admin::ClearTestCasesController < ApplicationController
  include Pagy::Backend
  load_resource :clear_test_case, class: 'Clear::TestCase'

  def index
    @pagy, @clear_test_cases = pagy(@clear_test_cases)
  end

  def update
    test_run = Clear::TestRun.find_by(id: clear_test_case_params[:test_run_id])
    test_result = test_run.get_test_result(clear_test_case.id)
    unless @clear_test_case.update(used_operators_data: test_result.used_operators_data)
      flash.now[:alert] = @clear_test_case.errors.full_messages.join(', ')
    end
    redirect_to admin_clear_test_run_clear_test_result_path(test_run, @clear_test_case)
  end

  def destroy
    @clear_test_case.destroy
    redirect_to admin_clear_test_cases_path
  end

  private

  def clear_test_case_params
    params.require(:clear_test_case).permit(:test_run_id)
  end
end
