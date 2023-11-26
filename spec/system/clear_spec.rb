require 'system_spec_helper'

describe 'Clears' do
  describe 'Creating a new clear', :js do
    before do
      allow(Clears::AssignChannelJob).to receive(:perform_later)
    end

    def select_stage(stage_code)
      find('label', text: 'Stage ids').click
      find_by_id('choices--clear_stage_ids-item-choice-1', text: stage_code).click
      # click away so that the dropdown closes and the add operator button is not covered
      find('body').click
    end

    def within_operator_form(used_operator = nil, edit: false, &)
      within(operator_form_css(used_operator, edit:), &)
    end

    def fill_in_operator_details(used_operator, edit: false)
      name, elite, level, skill, skill_level_option, id =
        used_operator.values_at(:name, :elite, :level, :skill, :skill_level_option, :operator_id)

      within_operator_form(used_operator, edit:) do
        unless edit
          find('label', text: 'Operator', exact: true).click
          find('div.choices__item--selectable', text: name, exact_text: true).click
        end
        find("label[for='#{mode}_#{id}_used_operator_elite_#{elite}']").click if elite

        return unless elite

        wait_for_turbo

        fill_in('Level', with: level) if level
        find("label[for='#{mode}_#{id}_used_operator_skill_#{skill}']").click if skill

        select skill_level_option, from: 'Skill level' if skill_level_option
      end
    end

    def add_an_operator(operator)
      used_operator = UsedOperator.new(operator)

      find('.operators__new_operator_btn').click

      fill_in_operator_details(used_operator)
      within_operator_form(used_operator) { click_button 'Add operator' }

      wait_for_operator_update_completed(used_operator)
      expect_page_have_operator_details(used_operator)
      expect_page_not_have_form(used_operator)
      used_operator
    end

    def operator_css(used_operator)
      "img[alt='#{used_operator.name}']"
    end

    def operator_form_css(used_operator, edit: false)
      if mobile_mode && edit
        "#mobile_operator_#{used_operator.operator_id}"
      else
        "##{mode}_operators__form_container"
      end
    end

    def expect_page_have_operator(used_operator)
      expect(page).to have_css(operator_css(used_operator))
    end

    def expect_page_not_have_operator(used_operator)
      expect(page).not_to have_css(operator_css(used_operator))
    end

    def expect_page_not_have_form(used_operator)
      expect(page).not_to have_css(operator_form_css(used_operator))
    end

    def select_an_operator(used_operator)
      if mode == :basic
        find(operator_css(used_operator)).ancestor('a').click
      else
        find(operator_css(used_operator)).ancestor('article').click_link('Edit operator')
      end
    end

    def wait_for_operator_update_completed(used_operator)
      # TODO: find better way, for some reason, waiting for the image which is part of same stream doesn't work
      expect(page).to have_css("#fields_operator_#{used_operator.operator_id}", visible: :all)
    end

    def delete_an_operator(operator)
      used_operator = UsedOperator.new(operator)
      expect_page_have_operator(used_operator)

      select_an_operator(used_operator)
      within_operator_form(used_operator, edit: true) do
        click_button('Delete operator')
      end

      expect_page_not_have_form(used_operator)
      expect(page).not_to have_css(operator_css(used_operator))
    end

    def expect_page_have_operator_details(used_operator)
      operator_card = find(operator_css(used_operator)).ancestor('article.operators__card')
      expect(operator_card).to have_content(used_operator.level) if used_operator.level
      expect(operator_card).to have_content(used_operator.skill_level_code) if used_operator.skill_level
      expect(operator_card).to have_css("img[alt='Elite #{used_operator.elite}']") if used_operator.elite
    end

    def edit_an_operator(operator)
      used_operator = UsedOperator.new(operator)
      expect_page_have_operator(used_operator)

      select_an_operator(used_operator)
      fill_in_operator_details(used_operator, edit: true)

      within_operator_form(used_operator, edit: true) do
        click_button('Update operator')
      end
      wait_for_operator_update_completed(used_operator)
      expect_page_have_operator_details(used_operator)
      expect_page_not_have_form(used_operator)
      used_operator
    end

    def fill_in_clear_detail
      fill_in 'Link', with: 'https://www.youtube.com/watch?v=R9XnYuyQEVM'
      fill_in 'Title', with: 'Test Clear'
      # Fill in title first so to trigger onChange event for iframe to appear
      expect(page).to have_css("iframe[src='https://www.youtube.com/embed/R9XnYuyQEVM']")
    end

    def visit_new_clear_page
      sign_in
      click_link 'Clear'
      expect(page).to have_content('Submit new clear')
    end

    shared_examples 'creating a new clear' do
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

        switch_mode
        new_used_operator = add_an_operator(operator: new_op, elite: 2, level: 90, skill: 1, skill_level: 7)

        add_an_operator(operator: deleted_op)
        delete_an_operator(operator: deleted_op)

        add_an_operator(operator: edited_op, elite: 1, level: 70, skill: 2, skill_level: 7)
        edited_used_operator = edit_an_operator(operator: edited_op, elite: 2, level: 90, skill: 3, skill_level: 10)

        click_button 'Create clear'

        expect(page).to have_content('Clear was successfully created!')

        new_clear = Clear.last
        expect(page).to have_content('0-1')
        expect(page).to have_current_path(clear_path(new_clear))
        expect(page).to have_css('iframe[src="https://youtube.com/embed/R9XnYuyQEVM"]')

        expect_page_have_operator_details(new_used_operator)
        expect_page_not_have_operator(deleted_op)
        expect_page_have_operator_details(edited_used_operator)

        expect(Clears::AssignChannelJob)
          .to have_received(:perform_later)
          .with(new_clear.id, 'https://youtube.com/watch?v=R9XnYuyQEVM')
      end
    end

    let(:mobile_mode) { false }

    def switch_mode
      nil
    end

    context 'when in basic mode' do
      let(:mode) { :basic }

      include_examples 'creating a new clear'
    end

    context 'when in detailed mode' do
      def switch_mode
        choose 'Detailed'
      end
      let(:mode) { :detailed }

      include_examples 'creating a new clear'
    end

    context 'when in mobile mode', :mobile do
      let(:mode) { :detailed }
      let(:mobile_mode) { true }

      include_examples 'creating a new clear'
    end
  end
end
