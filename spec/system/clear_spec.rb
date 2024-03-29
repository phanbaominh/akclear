require 'system_spec_helper'

describe 'Clears' do
  def open_stage_dropdown(single: false)
    find('label', text: single ? 'Stage' : "*\nStages").click
  end

  def select_stage(stage_code, single: false, required: false)
    choicesjs_select stage_code, from: single ? [("*\n" if required), 'Stage'].join : "*\nStages", single:
  end

  def within_operator_form(used_operator = nil, edit: false, &)
    within(operator_form_css(used_operator, edit:), &)
  end

  def operator_name_option_css
    'div.choices__item--selectable'
  end

  def show_operator_name_options
    find('label', text: 'Operator', exact_text: true).click
  end

  def select_operator_name(name)
    show_operator_name_options
    find(operator_name_option_css, text: name, exact_text: true).click
  end

  def fill_in_operator_details(used_operator, edit: false)
    name, elite, level, skill, skill_level_option, id =
      used_operator.values_at(:name, :elite, :level, :skill, :skill_level_option, :operator_id)

    within_operator_form(used_operator, edit:) do
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

  def select_operator_to_add(operator)
    within('.operators__new_operator_form') do
      find('div[aria-label="Select operator"]').click
      find(operator_name_option_css, text: operator.name, exact_text: true).click
    end

    click_add_operator_button
  end

  def add_an_operator(options)
    filter = options[:filter] || false
    operator = options.except(:filter)
    used_operator = UsedOperator.new(operator)

    select_operator_to_add(used_operator)
    return used_operator if filter

    if mode == :basic

      edit_an_operator(operator)
    else
      fill_in_operator_details(used_operator)
      within_operator_form(used_operator) { click_button 'Add operator' }

      wait_for_turbo
      # wait_for_operator_update_completed(used_operator)
      expect_page_have_operator_details(used_operator)
      expect_page_not_have_form(used_operator)
    end
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

  def expect_page_to_have_embeded_link
    expect_page_have_embeded_video
  end

  def select_an_operator(used_operator)
    if mode == :basic
      click_link "Edit operator #{used_operator.name}"
    else
      find(operator_css(used_operator)).ancestor('article').click_link('Edit operator')
    end
  end

  def wait_for_operator_update_completed(used_operator)
    # TODO: find better way, for some reason, waiting for the image which is part of same stream doesn't work
    # need to wait for all fields looks like, otherwise it will be inconsistent
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
    within '#clears_operators' do
      operator_card = find(operator_css(used_operator)).ancestor('article.operators__card')
      expect(operator_card).to have_content(used_operator.level) if used_operator.level
      expect(operator_card).to have_content(used_operator.skill_level_code) if used_operator.skill_level
      expect(operator_card).to have_css("img[alt='Elite #{used_operator.elite}']") if used_operator.elite
    end
  end

  def expect_page_have_embeded_video
    expect(page).to have_css("iframe[src='#{embeded_link}']")
  end

  def edit_an_operator(operator)
    used_operator = UsedOperator.new(operator)
    expect_page_have_operator(used_operator)

    select_an_operator(used_operator)
    fill_in_operator_details(used_operator, edit: true)

    within_operator_form(used_operator, edit: true) do
      click_button('Update operator')
    end
    wait_for_turbo
    # wait_for_operator_update_completed(used_operator)
    expect_page_have_operator_details(used_operator)
    expect_page_not_have_form(used_operator)
    used_operator
  end

  def fill_in_clear_detail
    fill_in 'Link', with: example_link
    fill_in 'Title', with: 'Test Clear'
    # Fill in title first so to trigger onChange event for iframe to appear
    expect_page_have_embeded_video
  end

  def visit_new_clear_page
    sign_in
    within('header .navbar') do
      click_link 'Clear'
    end
    expect(page).to have_content('Submit new clear')
  end

  def visit_edit_clear_page(clear)
    sign_in(clear.submitter)
    visit edit_clear_path(clear)
  end

  let(:mode) { :basic }
  let(:mobile_mode) { false }
  let(:example_link) { 'https://youtube.com/watch?v=R9XnYuyQEVM' }
  let(:embeded_link) { 'https://youtube.com/embed/R9XnYuyQEVM' }

  def switch_mode
    nil
  end

  describe 'Creating a new clear', :js do
    it 'does not allow more than 13 operators' do
      clear = create(:clear, :rejected, submitter: create(:user))
      ops = create_list(:operator, 13)
      ops.first(12).each do |op|
        create(:used_operator, clear:, operator: op)
      end

      visit_edit_clear_page(clear)
      add_an_operator(operator: ops.last)

      expect(page).to have_css(add_operator_button_css + ':disabled')
    end

    describe 'multiple stages' do
      def select_multiple_stages(stages)
        select_stage(stages.map(&:code))
        click_outside
      end

      it 'does not allows more than 5 stages' do
        stages = create_list(:stage, 6)

        visit_new_clear_page
        select_multiple_stages(stages.first(5))
        open_stage_dropdown
        expect(page).to have_content('Cannot select more than 5')
      end

      it 'creates a clear for each stage' do
        stages = [create(:stage, code: '1-ori_clear_stage'), create(:stage, code: '2-dup_clear_stage')]
        op = create(:operator)

        visit_new_clear_page

        fill_in 'Link', with: example_link
        click_outside

        expect(page).to have_content('A clear will be created for each stage chosen.')
        select_multiple_stages(stages)

        used_op = add_an_operator(operator: op, elite: 2)

        click_button 'Create clear'

        expect(page).to have_content('2 clears were successfully created!')

        expect(Clear.count).to eq(2)
        expect_page_to_have_embeded_link
        expect(page).to have_current_path(clear_path(Clear.first))
        expect(page).to have_content('1-ori_clear_stage')
        expect_page_have_operator_details(used_op)

        visit clear_path(Clear.last)
        expect_page_to_have_embeded_link
        expect(page).to have_content('2-dup_clear_stage')
        expect_page_have_operator_details(used_op)
      end
    end

    shared_examples 'creating a new clear' do
      it 'creates a new clear' do
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
        expect_page_have_embeded_video

        expect_page_have_operator_details(new_used_operator)
        expect_page_not_have_operator(deleted_op)
        expect_page_have_operator_details(edited_used_operator)

        expect(Clears::AssignChannelJob)
          .not_to have_received(:perform_later)
          .with(new_clear.id, 'https://youtube.com/watch?v=R9XnYuyQEVM')
      end
    end

    describe 'creating clear from scratch' do
      let_it_be(:new_op) do
        create(:operator, name: 'Amiya', rarity: Operator::FIVE_STARS, skill_number: 3)
      end
      let_it_be(:deleted_op) { create(:operator, name: 'Deleted op') }
      let_it_be(:edited_op) do
        create(:operator, name: 'Edited op', rarity: Operator::SIX_STARS, skill_number: 3)
      end
      let_it_be(:stage) { create(:stage, code: '0-1') }

      context 'when in basic mode' do
        include_examples 'creating a new clear'

        it 'does not allow duplicated operator' do
          op = create(:operator)

          visit_new_clear_page

          add_an_operator(operator: op)

          within('.operators__new_operator_form') do
            find('div[aria-label="Select operator"]').click
            expect(page).not_to have_css(operator_name_option_css, text: op.name, exact_text: true)
          end
        end
      end

      context 'when in detailed mode' do
        def switch_mode
          choose 'Detailed'
        end
        let(:mode) { :detailed }

        include_examples 'creating a new clear'

        it 'does not allow duplicated operator' do
          op = create(:operator)

          visit_new_clear_page

          switch_mode

          add_an_operator(operator: op)

          select_operator_to_add(new_op)

          within_operator_form do
            show_operator_name_options
            expect(page).not_to have_css(operator_name_option_css, text: op.name, exact_text: true)
          end
        end
      end

      context 'when in mobile mode', :mobile do
        let(:mode) { :detailed }
        let(:mobile_mode) { true }

        def switch_mode
          choose 'Detailed'
        end

        include_examples 'creating a new clear'
      end
    end

    describe 'create clear from existing squad' do
      it 'fills out the form with data from squad' do
        existing_clear = create(:clear)
        deleted_existing_used_op = create(:full_used_operator, clear: existing_clear)
        edited_existing_used_op = create(:full_used_operator, clear: existing_clear)
        new_op = create(:operator, skill_number: 2)

        sign_in

        visit clear_path(existing_clear)
        click_link 'Use squad'

        fill_in_clear_detail
        select_stage(existing_clear.stage.code)

        expect_page_have_operator_details(deleted_existing_used_op)
        expect_page_have_operator_details(edited_existing_used_op)
        new_used_op = add_an_operator(operator: new_op, elite: 1, level: 50, skill: 1, skill_level: 7)
        delete_an_operator(operator: deleted_existing_used_op.operator)
        newly_edited_existing_used_op = edit_an_operator(operator: edited_existing_used_op.operator, elite: 1,
                                                         level: 50, skill: 1, skill_level: 7)

        click_button 'Create clear'

        expect(page).to have_content('Clear was successfully created!')

        new_clear = Clear.last
        expect(page).to have_current_path(clear_path(new_clear))

        expect_page_have_operator_details(new_used_op)
        expect_page_not_have_operator(deleted_existing_used_op.operator)
        expect_page_have_operator_details(newly_edited_existing_used_op)
      end
    end

    describe 'creating clear from job' do
      it 'fills out the form with data from job' do
        ops = create_list(:operator, 5, skill_number: 2)
        job_stage = create(:stage, code: '0-1')
        used_operators = ops.first(3).map do |op|
          build(:used_operator, operator: op, elite: 2, level: 90, skill: 1,
                                skill_level: 7)
        end
        channel = create(:channel)
        job = create(:extract_clear_data_from_video_job, :completed, data: {
                       link: example_link,
                       stage_id: job_stage.id,
                       used_operators_attributes: used_operators.map(&:attributes),
                       channel_id: channel.id,
                       name: 'Test Video'
                     }, stage: job_stage, video_url: example_link, channel:)

        admin = sign_in_as_admin

        click_link 'Admin'

        click_link 'Import clear jobs'

        within("#extract_clear_data_from_video_job_#{job.id}") do
          expect(page).to have_content('0-1')
          expect(page).to have_content('Test Video')
          click_link 'Create clear'
        end

        expect(page).to have_current_path(new_admin_clear_from_job_path(job_id: job.id))
        expect(page).to have_field('Link', with: example_link)
        expect(page).to have_content('0-1')
        used_operators.each do |used_op|
          expect_page_have_operator_details(used_op)
        end

        click_button 'Create clear'

        expect(page).to have_content('Clear was successfully created!')

        new_clear = Clear.last
        expect(page).to have_content('0-1')
        expect(page).to have_current_path(clear_path(new_clear))
        expect(page).to have_content('Verified')
        find('details', text: "Verified by #{admin.username}").click
        expect(page).to have_content('Clear was submitted by trusted users and was automatically verified.')
        expect_page_have_embeded_video

        used_operators.each do |used_op|
          expect_page_have_operator_details(used_op)
        end
        expect(job.reload).to be_clear_created
        expect(new_clear.channel).to eq(job.channel)
      end
    end
  end

  describe 'Editing a clear', :js do
    shared_examples 'editing a clear' do
      it 'updates the clear' do
        new_op = create(:operator, name: 'Amiya', rarity: Operator::FIVE_STARS, skill_number: 3)
        deleted_op = create(:operator, name: 'Deleted op')
        edited_op = create(:operator, name: 'Edited op', rarity: Operator::SIX_STARS, skill_number: 3)
        stage = create(:stage, code: '0-1')
        create(:stage, code: '0-2')

        clear = create(:clear, :rejected, stage:, link: example_link)
        create(:used_operator, operator: edited_op, elite: 1, level: 70, skill: 2, skill_level: 7, clear:)
        create(:used_operator, operator: deleted_op, clear:)

        visit_edit_clear_page(clear)

        expect_page_have_embeded_video

        select_stage('0-2', single: true, required: true)

        switch_mode

        new_used_operator = add_an_operator(operator: new_op, elite: 2, level: 90, skill: 1, skill_level: 7)

        # avoid overriding new op and delete op fields when submitting due to
        # having same field index due to Time.now usage
        Timecop.travel(1.second.from_now)

        delete_an_operator(operator: deleted_op)

        Timecop.travel(1.second.from_now)

        edited_used_operator = edit_an_operator(operator: edited_op, elite: 2, level: 90, skill: 3, skill_level: 10)

        click_button 'Update clear'

        # this is for wait_for_turbo
        expect(page).to have_content('Clear was successfully updated!')

        expect(page).to have_content('0-2')
        expect(page).to have_current_path(clear_path(clear))
        expect_page_have_embeded_video

        expect_page_have_operator_details(new_used_operator)
        expect_page_not_have_operator(deleted_op)
        expect_page_have_operator_details(edited_used_operator)

        expect(Clears::AssignChannelJob)
          .not_to have_received(:perform_later)
          .with(clear.id, 'https://youtube.com/watch?v=R9XnYuyQEVM')
      end
    end

    context 'when in basic mode' do
      include_examples 'editing a clear'
    end
  end

  describe 'Filtering a clear', :js do
    let_it_be(:annihilation) { create(:annihilation, name: 'Chernobog', game_id: 'camp_r_01') }
    let_it_be(:episode) { create(:episode, number: 1) }
    let_it_be(:event) { create(:event, name: 'Test Event') }

    let_it_be(:annihilation_stage) { create(:stage, code: 'Chernobog', stageable: annihilation) }
    let_it_be(:episode_stage) { create(:stage, code: '1-1', stageable: episode) }
    let_it_be(:event_stage) { create(:stage, code: 'EV-1', stageable: event, game_id: 'ev_01') }

    let_it_be(:annihilation_clear) { create(:clear, stage: annihilation_stage) }
    let_it_be(:annihilation_clear_with_no_operatoar) { create(:clear, name: 'no op clear', stage: annihilation_stage) }
    let_it_be(:episode_clear) { create(:clear, stage: episode_stage) }
    let_it_be(:event_clear) { create(:clear, stage: event_stage) }

    let_it_be(:filtered_op) { create(:operator, name: 'Filtered op') }
    let_it_be(:non_filtered_op) { create(:operator, name: 'Non filtered op') }

    let_it_be(:filtered_used_op) { create(:used_operator, operator: filtered_op, clear: annihilation_clear) }
    let_it_be(:filtered_used_op_2) { create(:used_operator, operator: filtered_op, clear: episode_clear) }

    let_it_be(:non_filtered_used_op) { create(:used_operator, operator: non_filtered_op, clear: event_clear) }
    let_it_be(:non_filtered_used_op_2) { create(:used_operator, operator: non_filtered_op, clear: episode_clear) }

    def clear_card_css
      '.clears_card'
    end

    def expect_page_to_have_clear(clear)
      all(clear_card_css, text: clear.name || clear.stage.code).each do |card|
        valid = true
        within card do
          valid &&= if clear.stage.challenge_mode?
                      page.has_css?('img[alt="Challenge mode"]')
                    else
                      page.has_no_css?('img[alt="Challenge mode"]')
                    end
        end
        next unless valid

        within card do
          valid &&= if clear.stage.has_environments?
                      page.has_css?("img[alt~='#{clear.stage.environment.titleize}']")

                    else
                      page.has_no_css?('img[alt~="Environment"]')
                    end
        end
        return true if valid
      end
      RSpec::Expectations.fail_with("page does not have clear with stage #{clear.stage.code_with_mods}")
    end

    def expect_page_not_to_have_clear(clear)
      expect(page).not_to have_css(clear_card_css, text: clear.name || clear.stage.code)
    end

    def expect_page_to_only_have_clears(clears)
      clears.each do |clear|
        expect_page_to_have_clear(clear)
      end
      expect(page).to have_css(clear_card_css, count: clears.size)
    end

    def apply_filters
      click_button 'Search'
      wait_for_turbo
    end

    def switch_to_cm
      find('label', text: 'Challenge mode').click
    end

    it 'paginates' do
      create_list(:clear, 20)

      visit clears_path

      expect(page).to have_css(clear_card_css, count: 20)
      expect(page).to have_css('.page', count: 4)
      expect(page).to have_css('.page.current', text: '1')
      expect(page).to have_link('2')

      click_link '2'
      expect(page).to have_css(clear_card_css, count: 4)
      expect(page).to have_css('.page.current', text: '2')
      expect(page).to have_link('1')
    end

    context 'when in basic mode' do
      it 'filters correctly' do
        visit clears_path

        switch_mode

        expect_page_to_have_clear(annihilation_clear)
        expect_page_to_have_clear(episode_clear)
        expect_page_to_have_clear(event_clear)

        add_an_operator(operator: filtered_op, filter: true)

        wait_for_turbo

        apply_filters

        expect_page_to_have_clear(annihilation_clear)
        expect_page_to_have_clear(episode_clear)
        expect_page_not_to_have_clear(event_clear)

        select_stage(annihilation_stage.code, single: true)

        apply_filters

        expect_page_to_have_clear(annihilation_clear)
        expect_page_not_to_have_clear(annihilation_clear_with_no_operatoar)
        expect_page_not_to_have_clear(episode_clear)
        expect_page_not_to_have_clear(event_clear)

        click_button 'Delete operator'

        wait_for_turbo

        apply_filters

        expect_page_to_have_clear(annihilation_clear)
        expect_page_to_have_clear(annihilation_clear_with_no_operatoar)
        expect_page_not_to_have_clear(episode_clear)
        expect_page_not_to_have_clear(event_clear)
      end
    end

    context 'when in detailed mode' do
      let(:mode) { :detailed }

      it 'filters correctly' do
        visit clears_path
        choose 'Detailed'

        expect_page_to_have_clear(annihilation_clear)
        expect_page_to_have_clear(episode_clear)
        expect_page_to_have_clear(event_clear)

        add_an_operator(operator: filtered_op, filter: true)

        wait_for_turbo

        apply_filters

        expect_page_to_have_clear(annihilation_clear)
        expect_page_to_have_clear(episode_clear)
        expect_page_not_to_have_clear(event_clear)

        choicesjs_select 'Annihilation', from: 'Stage type'
        choicesjs_select 'Annihilation 01 - Chernobog', from: 'Stage'

        apply_filters

        expect_page_to_have_clear(annihilation_clear)
        expect_page_not_to_have_clear(annihilation_clear_with_no_operatoar)
        expect_page_not_to_have_clear(episode_clear)
        expect_page_not_to_have_clear(event_clear)

        click_button 'Delete operator'

        wait_for_turbo

        apply_filters

        expect_page_to_have_clear(annihilation_clear)
        expect_page_to_have_clear(annihilation_clear_with_no_operatoar)
        expect_page_not_to_have_clear(episode_clear)
        expect_page_not_to_have_clear(event_clear)
      end

      it 'filters event correctly' do
        cm_event_stage = create(:stage, code: 'EV-1', game_id: 'ev_01#f#', stageable: event)
        cm_event_clear = create(:clear, stage: cm_event_stage)

        visit clears_path
        choose 'Detailed'

        choicesjs_select 'Event', from: 'Stage type'
        choicesjs_select 'Test Event', from: 'Event'
        apply_filters
        expect_page_to_only_have_clears([event_clear, cm_event_clear])

        choicesjs_select('Test Event: EV-1', from: 'Stage')
        apply_filters
        expect_page_to_only_have_clears([event_clear])

        switch_to_cm

        choicesjs_select('Test Event: EV-1 CM', from: 'Stage')
        apply_filters
        expect_page_to_only_have_clears([cm_event_clear])
      end

      context 'when filters by episode' do
        it 'filters episode < 9 correctly' do
          cm_episode_stage = create(:stage, :challenge_mode, stageable: episode, code: '1-1')
          cm_episode_stage_clear = create(:clear, stage: cm_episode_stage)

          visit clears_path
          choose 'Detailed'

          choicesjs_select 'Episode', from: 'Stage type'
          choicesjs_select 'Episode 1', from: 'Episode'
          wait_for_turbo
          apply_filters
          expect_page_to_only_have_clears([episode_clear, cm_episode_stage_clear])

          choicesjs_select('Episode 1: 1-1', from: 'Stage')
          apply_filters
          expect_page_to_only_have_clears([episode_clear])

          switch_to_cm
          choicesjs_select('Episode 1: 1-1 CM', from: 'Stage')
          apply_filters
          expect_page_to_only_have_clears([cm_episode_stage_clear])
        end

        it 'filters episode = 9 correctly' do
          episode = create(:episode, number: 9)
          story_episode_stage = create(:story_stage, stageable: episode, code: '9-1')
          standard_episode_stage = create(:standard_stage, stageable: episode, code: '9-1')
          cm_standard_episode_stage = create(:standard_stage, :challenge_mode, stageable: episode, code: '9-1')

          story_episode_stage_clear = create(:clear, stage: story_episode_stage)
          standard_episode_stage_clear = create(:clear, stage: standard_episode_stage)
          cm_standard_episode_stage_clear = create(:clear, stage: cm_standard_episode_stage)

          visit clears_path
          choose 'Detailed'

          choicesjs_select 'Episode', from: 'Stage type'
          choicesjs_select 'Episode 9', from: 'Episode'
          wait_for_turbo
          apply_filters
          expect_page_to_only_have_clears(
            [story_episode_stage_clear, standard_episode_stage_clear, cm_standard_episode_stage_clear]
          )

          choose 'story'
          choicesjs_select('Episode 9: 9-1 story', from: 'Stage')
          apply_filters
          expect_page_to_only_have_clears(
            [story_episode_stage_clear]
          )

          choose 'standard'
          choicesjs_select('Episode 9: 9-1 standard', from: 'Stage')
          apply_filters
          expect_page_to_only_have_clears(
            [standard_episode_stage_clear]
          )

          switch_to_cm
          choicesjs_select('Episode 9: 9-1 CM standard', from: 'Stage')
          apply_filters
          expect_page_to_only_have_clears(
            [cm_standard_episode_stage_clear]
          )
        end

        it 'filters episode > 9 correctly' do
          episode = create(:episode, number: 10)
          story_episode_stage = create(:story_stage, stageable: episode, code: '10-1')
          standard_episode_stage = create(:standard_stage, stageable: episode, code: '10-1')
          adverse_episode_stage = create(:adverse_stage, stageable: episode, code: '10-1')

          story_episode_stage_clear = create(:clear, stage: story_episode_stage)
          standard_episode_stage_clear = create(:clear, stage: standard_episode_stage)
          adverse_episode_stage_clear = create(:clear, stage: adverse_episode_stage)

          visit clears_path
          choose 'Detailed'

          choicesjs_select 'Episode', from: 'Stage type'
          choicesjs_select 'Episode 10', from: 'Episode'
          wait_for_turbo
          apply_filters
          expect_page_to_only_have_clears(
            [story_episode_stage_clear, standard_episode_stage_clear, adverse_episode_stage_clear]
          )

          choose 'story'
          choicesjs_select('Episode 10: 10-1 story', from: 'Stage')
          apply_filters
          expect_page_to_only_have_clears(
            [story_episode_stage_clear]
          )

          choose 'standard'
          choicesjs_select('Episode 10: 10-1 standard', from: 'Stage')
          apply_filters
          expect_page_to_only_have_clears(
            [standard_episode_stage_clear]
          )

          choose 'adverse'
          choicesjs_select('Episode 10: 10-1 adverse', from: 'Stage')
          apply_filters
          expect_page_to_only_have_clears(
            [adverse_episode_stage_clear]
          )
        end
      end
    end
  end

  describe 'Favorite a clear', :js do
    let_it_be(:clear) { create(:clear, name: 'test clear') }

    context 'when not signed in' do
      it 'redirects to sign in page' do
        visit clear_path(clear)

        click_button 'Favorite'

        expect(page).to have_current_path(sign_in_path)
      end
    end

    it 'favorites a clear' do
      create_list(:used_operator, 3, clear:)

      sign_in

      visit clears_path

      click_link 'test clear'

      expect(page).to have_current_path(clear_path(clear))

      click_button 'Favorite'

      expect(page.find_button('Unfavorite')).to have_content('1')

      find('details', text: 'Profile').click

      click_link('Favorites')

      expect(page).to have_content('test clear')

      click_link 'test clear'

      click_button 'Unfavorite'

      expect(page.find_button('Favorite')).to have_content('0')

      find('details', text: 'Profile').click

      click_link('Favorites')

      expect(page).not_to have_content('test clear')
    end
  end
end
