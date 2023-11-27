require 'system_spec_helper'

describe 'Clears' do
  def select_stage(stage_code, edit: false, index: 1)
    find('label', text: edit ? 'Stage' : 'Stage ids').click
    if edit
      find_by_id("choices--clear_stage_id-item-choice-#{index}", text: stage_code).click
    else
      find_by_id("choices--clear_stage_ids-item-choice-#{index}", text: stage_code).click
    end
    # click away so that the dropdown closes and the add operator button is not covered
    find('body').click
  end

  def within_operator_form(used_operator = nil, edit: false, &)
    within(operator_form_css(used_operator, edit:), &)
  end

  def operator_name_option_css
    'div.choices__item--selectable'
  end

  def show_operator_name_options
    find('label', text: 'Operator', exact: true).click
  end

  def select_operator_name(name)
    show_operator_name_options
    find(operator_name_option_css, text: name, exact_text: true).click
  end

  def fill_in_operator_details(used_operator, edit: false)
    name, elite, level, skill, skill_level_option, id =
      used_operator.values_at(:name, :elite, :level, :skill, :skill_level_option, :operator_id)

    within_operator_form(used_operator, edit:) do
      select_operator_name(name) unless edit
      find("label[for='#{mode}_#{id}_used_operator_elite_#{elite}']").click if elite

      return unless elite

      wait_for_turbo

      fill_in('Level', with: level) if level
      find("label[for='#{mode}_#{id}_used_operator_skill_#{skill}']").click if skill

      select skill_level_option, from: 'Skill level' if skill_level_option
    end
  end

  def add_operator_button_css
    '.operators__new_operator_btn'
  end

  def click_add_operator_button
    find(add_operator_button_css).click
  end

  def add_an_operator(operator)
    used_operator = UsedOperator.new(operator)

    click_add_operator_button

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

  def visit_edit_clear_page(clear)
    sign_in(clear.submitter)
    visit edit_clear_path(clear)
  end

  let(:mobile_mode) { false }

  def switch_mode
    nil
  end

  describe 'Creating a new clear', :js do
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

    context 'when in basic mode' do
      let(:mode) { :basic }

      include_examples 'creating a new clear'

      it 'does not allow duplicated operator' do
        op = create(:operator)

        visit_new_clear_page

        add_an_operator(operator: op)

        click_add_operator_button

        within_operator_form do
          show_operator_name_options
          expect(page).not_to have_css(operator_name_option_css, text: op.name, exact_text: true)
        end
      end

      it 'does not allow more than 13 operators' do
        clear = create(:clear, :declined, submitter: create(:user))
        ops = create_list(:operator, 13)
        ops.first(12).each do |op|
          create(:used_operator, clear:, operator: op)
        end

        visit_edit_clear_page(clear)
        add_an_operator(operator: ops.last)

        expect(page).to have_css(add_operator_button_css + ':disabled')
      end

      it 'allows multiple stages' do
      end
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

  describe 'Editing a clear', :js do
    shared_examples 'editing a clear' do
      it 'updates the clear' do
        new_op = create(:operator, name: 'Amiya', rarity: Operator::FIVE_STARS,
                                   skill_game_ids: %w[amiya_1 amiya_2 amiya_3])
        deleted_op = create(:operator, name: 'Deleted op')
        edited_op = create(:operator, name: 'Edited op', rarity: Operator::SIX_STARS,
                                      skill_game_ids: %w[edit_1 edit_2 edit_3])
        stage = create(:stage, code: '0-1')
        create(:stage, code: '0-2')

        clear = create(:clear, :declined, stage:, link: 'https://www.youtube.com/watch?v=R9XnYuyQEVM')
        create(:used_operator, operator: edited_op, elite: 1, level: 70, skill: 2, skill_level: 7, clear:)
        create(:used_operator, operator: deleted_op, clear:)

        visit_edit_clear_page(clear)

        expect(page).to have_css("iframe[src='https://youtube.com/embed/R9XnYuyQEVM']")

        select_stage('0-2', edit: true, index: 3)

        switch_mode

        new_used_operator = add_an_operator(operator: new_op, elite: 2, level: 90, skill: 1, skill_level: 7)

        # avoid overriding new op and delete op fields when submitting due to
        # having same field index due to Time.now usage
        Timecop.travel(1.second.from_now)

        delete_an_operator(operator: deleted_op)

        edited_used_operator = edit_an_operator(operator: edited_op, elite: 2, level: 90, skill: 3, skill_level: 10)

        click_button 'Update clear'

        # this is for wait_for_turbo
        expect(page).to have_content('Clear was successfully updated!')

        expect(page).to have_content('0-2')
        expect(page).to have_current_path(clear_path(clear))
        expect(page).to have_css('iframe[src="https://youtube.com/embed/R9XnYuyQEVM"]')

        expect_page_have_operator_details(new_used_operator)
        expect_page_not_have_operator(deleted_op)
        expect_page_have_operator_details(edited_used_operator)

        expect(Clears::AssignChannelJob)
          .not_to have_received(:perform_later)
          .with(clear.id, 'https://youtube.com/watch?v=R9XnYuyQEVM')
      end
    end

    context 'when in basic mode' do
      let(:mode) { :basic }

      include_examples 'editing a clear'
    end
  end
end
