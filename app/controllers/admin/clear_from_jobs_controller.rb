module Admin
  class ClearFromJobsController < AdminController
    include ClearFilterable
    def new
      @job = ExtractClearDataFromVideoJob.find_by(id: params[:job_id])
      return redirect_to(new_clear_path) unless @job.completed?

      set_modifying_clear
      @clear = @job.clear
      clear_spec_session['used_operators_attributes'] = {}
      @clear.used_operators.each_with_index do |used_operator, index|
        clear_spec_session['used_operators_attributes'][index.to_s] = used_operator.attributes.slice(
          'operator_id', 'level', 'elite', 'skill'
        )
      end
      render 'clears/new'
    end
  end
end
