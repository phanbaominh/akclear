require 'system_spec_helper'

describe 'Clears' do
  describe 'Creating a new clear', :js do
    before do
      allow(Clears::AssignChannelJob).to receive(:perform_later)
    end

    def select_stage(stage_code)
      find('label', text: 'Stage ids').click
      find_by_id('choices--clear_stage_ids-item-choice-1', text: stage_code).click
    end

    def within_operator_form(&)
      within('#basic_operators__form_container', &)
    end

    def fill_in_operator_details(used_operator, edit: false)
      name, elite, level, skill, skill_level_option, id =
        used_operator.values_at(:name, :elite, :level, :skill, :skill_level_option, :operator_id)

      within_operator_form do
        unless edit
          find('label', text: 'Operator', exact: true).click
          find('div.choices__item--selectable', text: name, exact_text: true).click
        end
        find("label[for='basic_#{id}_used_operator_elite_#{elite}']").click if elite

        fill_in('Level', with: level) if level
        find("label[for='basic_#{id}_used_operator_skill_#{skill}']").click if skill

        select skill_level_option, from: 'Skill level' if skill_level_option
      end
    end

    def add_an_operator(operator)
      used_operator = UsedOperator.new(operator)

      find('.operators__new_operator_btn').click

      fill_in_operator_details(used_operator)
      within_operator_form { click_button 'Add operator' }

      # TODO: find better way, for some reason, waiting for the image which is part of same stream doesn't work
      wait_for_operator_update_completed(used_operator)
    end

    def operator_css(used_operator)
      "img[alt='#{used_operator.name}']"
    end

    def expect_page_have_operator(used_operator)
      expect(page).to have_css(operator_css(used_operator))
    end

    def expect_page_not_have_operator(used_operator)
      expect(page).not_to have_css(operator_css(used_operator))
    end

    def select_an_operator(used_operator)
      find(operator_css(used_operator)).ancestor('a').click
    end

    def wait_for_operator_update_completed(used_operator)
      expect(page).to have_css("#fields_operator_#{used_operator.operator_id}", visible: :all)
    end

    def delete_an_operator(operator)
      used_operator = UsedOperator.new(operator)
      expect_page_have_operator(used_operator)

      select_an_operator(used_operator)
      within_operator_form do
        click_button('Delete operator')
      end

      expect(page).not_to have_css('#basic_operators__form_container')
      expect(page).not_to have_css(operator_css(used_operator))
    end

    def edit_an_operator(operator)
      used_operator = UsedOperator.new(operator)
      expect_page_have_operator(used_operator)

      select_an_operator(used_operator)
      fill_in_operator_details(used_operator, edit: true)

      within_operator_form do
        click_button('Update operator')
      end
      wait_for_operator_update_completed(used_operator)
    end

    def fill_in_clear_detail
      fill_in 'Link', with: 'https://www.youtube.com/watch?v=R9XnYuyQEVM'
      fill_in 'Title', with: 'Test Clear'
      expect(page).to have_css("iframe[src='https://www.youtube.com/embed/R9XnYuyQEVM']")
    end

    def visit_new_clear_page
      sign_in
      click_link 'Clear'
      expect(page).to have_content('Submit new clear')
    end

    it 'creates a new clear' do
      new_op = create(:operator, name: 'Amiya', rarity: Operator::FIVE_STARS,
                                 skill_game_ids: %w[amiya_1 amiya_2 amiya_3])
      deleted_op = create(:operator, name: 'Deleted op')
      edited_op = create(:operator, name: 'Edited op', rarity: Operator::SIX_STARS,
                                    skill_game_ids: %w[edit_1 edit_2 edit_3])
      create(:stage, code: '0-1')

      visit_new_clear_page

      fill_in_clear_detail

      select_stage('0-1')

      add_an_operator(operator: new_op, elite: 2, level: 90, skill: 1, skill_level: 7)

      add_an_operator(operator: deleted_op)
      delete_an_operator(operator: deleted_op)

      add_an_operator(operator: edited_op, elite: 1, level: 70, skill: 2, skill_level: 7)
      edit_an_operator(operator: edited_op, elite: 2, level: 90, skill: 3, skill_level: 10)

      click_button 'Create clear'

      new_clear = Clear.last
      expect(page).to have_current_path(clear_path(new_clear))
      expect(page).to have_content('0-1')
      expect(page).to have_css('iframe[src="https://youtube.com/embed/R9XnYuyQEVM"]')
      expect_page_have_operator(new_op)
      expect_page_not_have_operator(deleted_op)
      expect_page_have_operator(edited_op)

      expect(Clears::AssignChannelJob)
        .to have_received(:perform_later)
        .with(new_clear.id, 'https://youtube.com/watch?v=R9XnYuyQEVM')
    end
  end
end
