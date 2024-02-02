# frozen_string_literal: true

class Admin::ClearTestResultsController < ApplicationController
  load_resource :clear_test_run, class: 'ClearImage::TestRun'

  def index
    @clear_test_run.latest_size = params.dig(:clear_test_run, :latest_size) || 5
    @clear_test_results = @clear_test_run.test_results
    ClearImage::TestResult.preload_test_case(@clear_test_results)
  end

  def show
    get_clear_test_result
    preload_operators_data
  end

  def update
    get_clear_test_result
    @clear_test_result.configuration = params[:clear_test_result][:configuration].permit!.to_h
    @clear_test_result.rerun!
    redirect_to admin_clear_test_run_clear_test_result_path(@clear_test_run, @clear_test_result.test_case_id)
  end

  private

  def preload_operators_data
    I18n.with_locale(@clear_test_result.language) do
      Operator.build_translations_cache(Operator.where(id: @clear_test_result.all_operators.pluck(:operator_id)))
    end
    ActiveRecord::Associations::Preloader.new(
      records: @clear_test_result.all_operators,
      associations: [:operator]
    ).call
  end

  def get_clear_test_result
    @clear_test_result = ClearImage::TestResult.new(test_case_id: params[:id], test_run_id: @clear_test_run.id)
  end
end
