require 'system_spec_helper'

describe 'Clears' do
  describe 'New clear', :js do
    before do
      allow(Clears::AssignChannelJob).to receive(:perform_later)
    end

    def select_an_operator(operator)
      name, elite, level, skill, skill_level = operator.values_at(:name, :elite, :level, :skill, :skill_level)

      within('#basic_operators__form_container') do
        find('label', text: 'Operator', exact: true).click
        find('div.choices__item--selectable', text: name, exact_text: true).click
        find("label[for='basic_#{operator[:id]}_used_operator_elite_#{elite}']").click
        fill_in('Level', with: level)
        find("label[for='basic_#{operator[:id]}_used_operator_skill_#{skill}']").click
        select skill_level, from: 'Skill level'
        click_button 'Add operator'
      end
      # TODO: find better way, for some reason, waiting for the image which is part of same stream doesn't work
      expect(page).to have_css("#fields_operator_#{operator[:id]}", visible: :all)
    end

    it 'creates a new clear' do
      operator = create(:operator, name: 'Amiya', rarity: Operator::FIVE_STARS,
                                   skill_game_ids: %w[amiya_1 amiya_2 amiya_3])
      stage = create(:stage, code: '0-1')

      sign_in
      click_link 'Clear'
      expect(page).to have_content('Submit new clear')

      fill_in 'Link', with: 'https://www.youtube.com/watch?v=R9XnYuyQEVM'
      fill_in 'Name', with: 'Test clear'
      expect(page).to have_css('iframe[src="https://www.youtube.com/embed/R9XnYuyQEVM"]')
      find('label', text: 'Stage ids').click
      find_by_id('choices--clear_stage_ids-item-choice-1', text: '0-1').click
      find('.operators__new_operator_btn').click

      select_an_operator({ name: 'Amiya', elite: 2, level: 90, skill: 1, skill_level: 7, id: operator.id })

      click_button 'Create clear'

      new_clear = Clear.last
      expect(page).to have_current_path(clear_path(new_clear))
      expect(page).to have_content('0-1')
      expect(page).to have_css('iframe[src="https://youtube.com/embed/R9XnYuyQEVM"]')
      expect(page).to have_css('img[alt="Amiya"]')

      expect(Clears::AssignChannelJob).to have_received(:perform_later).with(new_clear.id, 'https://youtube.com/watch?v=R9XnYuyQEVM')
    end
  end
end
