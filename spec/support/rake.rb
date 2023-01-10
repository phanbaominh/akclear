require 'rails_helper'
require 'rake'

RSpec.shared_context 'rake' do |input_task_name = nil|
  subject         { rake[task_name] }

  let(:rake)      { Rake::Application.new }
  let(:task_name) { input_task_name || self.class.top_level_description }
  let(:task_path) do
    task_name_parts = task_name.split(':')
    if self.class.metadata[:cronjobs]
      "lib/tasks/cronjobs/#{task_name_parts[1]}"
    elsif task_name_parts.length > 1
      "lib/tasks/#{task_name_parts.take(task_name_parts.length - 1).join('/')}"
    else
      "lib/tasks/#{task_name_parts.first}"
    end
  end

  def loaded_files_excluding_current_rake_file
    $LOADED_FEATURES.reject { |file| file == Rails.root.join("#{task_path}.rake").to_s }
  end

  before do
    Rake.application = rake
    Rake.application.rake_require(task_path, [Rails.root.to_s], loaded_files_excluding_current_rake_file)

    Rake::Task.define_task(:environment)
  end
end
