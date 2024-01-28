# frozen_string_literal: true

class Admin::ClearTestRunsController < ApplicationController
  def show
    @test_run = Clear::TestRun.find(params[:id])
  end

  def new
    @test_run = Clear::TestRun.new(clear_test_run_params)
  end

  def create
    @test_run = Clear::TestRun.new(clear_test_run_params)
    @test_run.save!
    Clears::StartTestRunJob.perform_later(@test_run.id)
    redirect_to admin_clear_test_run_path(@test_run)
  end

  private

  def clear_test_run_params
    return {} if params[:clear_test_run].blank? && action_name == 'new'

    params.require(:clear_test_run).permit(:test_count, :all, test_case_ids: [])
  end
end
