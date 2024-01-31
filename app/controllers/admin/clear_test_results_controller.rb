# frozen_string_literal: true

class Admin::ClearTestResultsController < ApplicationController
  load_resource :clear_test_run, class: 'ClearImage::TestRun'

  def index
    # can choose to compare to how many latest test results deaulft: 5
    @clear_test_results = @clear_test_run.test_results
    ClearImage::TestResult.preload_test_case(@clear_test_results)
  end

  def show
    @clear_test_result = ClearImage::TestResult.new(test_case_id: params[:id], test_run_id: @clear_test_run.id)
    I18n.with_locale(@clear_test_result.language) do
      Operator.build_translations_cache(Operator.where(id: @clear_test_result.all_operators.pluck(:operator_id)))
    end
    ActiveRecord::Associations::Preloader.new(
      records: @clear_test_result.all_operators,
      associations: [:operator]
    ).call
  end
end
