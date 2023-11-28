require 'system_spec_helper'

describe 'Creating clear from job' do
  describe 'creating clear from job' do
    let(:example_link) { 'https://youtube.com/watch?v=R9XnYuyQEVM' }

    it 'fills out the form with data from job' do
      ops = create_list(:operator, 5)
      job_stage = create(:stage, code: '0-1')
      job = create(:extract_clear_data_from_video_job, :completed, data: {
                     link: example_link,
                     stage_id: job_stage.id,
                     used_operators_attributes: ops.first(3).map do |op|
                                                  build(:used_operator, operator: op, elite: 2, level: 90, skill: 1,
                                                                        skill_level: 7).attributes
                                                end
                   })

      sign_in_as_admin

      click_link 'Admin'

      click_link 'Import clear jobs'

      within("#extract_clear_data_from_video_job_#{job.id}") do
        expect(page).to have_content('0-1')
        expect(page).to have_content(example_link)
        click_link 'Create clear'
      end

    end
  end
end
