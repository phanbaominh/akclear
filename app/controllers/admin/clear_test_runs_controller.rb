# frozen_string_literal: true

class Admin::ClearTestRunsController < ApplicationController
  def show
    @test_run = ClearImage::TestRun.find(params[:id])
  end

  def new
    @test_run = ClearImage::TestRun.new(clear_test_run_params)
  end

  def create
    @test_run = ClearImage::TestRun.new(clear_test_run_params)
    @test_run.save!
    Clears::StartTestRunJob.perform_later(@test_run.id)
    redirect_to admin_clear_test_run_path(@test_run)
  end

  def update
    @test_run = ClearImage::TestRun.find(params[:id])
    if @test_run.update(clear_test_run_params)
      redirect_to admin_clear_test_run_clear_test_results_url(@test_run)
    else
      render :show
    end
  end

  def destroy
    @test_run = ClearImage::TestRun.find(params[:id])
    @test_run.destroy
    redirect_to new_admin_clear_test_run_url
  end

  private

  def clear_test_run_params
    return {} if params[:clear_test_run].blank? && action_name == 'new'

    params.require(:clear_test_run).permit(:name, :note, :test_count, :all, test_case_ids: [],
                                                                            configuration: [{ en: {} }, { 'zh-CN': {} }, { jp: {} }])
  end
end
