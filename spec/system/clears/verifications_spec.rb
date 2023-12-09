require 'system_spec_helper'

describe 'Verifications', :js do
  def operator_css(used_operator)
    "img[alt='#{used_operator.name}']"
  end

  def expect_operator_verification(used_operator, status)
    operator_card = find(operator_css(used_operator)).ancestor('article.operators__card')
    expect(operator_card).to have_css("svg[alt='#{status}']")
  end

  def expect_page_have_operator_details(used_operator)
    expect(page).to have_content(used_operator.name)
    operator_card = find(operator_css(used_operator)).ancestor('article.operators__card')
    expect(operator_card).to have_content(used_operator.level) if used_operator.level
    expect(operator_card).to have_content(used_operator.skill_level_code) if used_operator.skill_level
    expect(operator_card).to have_css("img[alt='Elite #{used_operator.elite}']") if used_operator.elite
  end

  context 'when normal user' do
    it 'cannot verify a clear' do
      clear = create(:clear)
      sign_in

      visit clear_path(clear)

      expect(page).not_to have_button('Verify')
    end
  end

  context 'when verifier' do
    it 'can verify a clear' do
      stage = create(:stage, code: '1-1')
      clear = create(:clear, stage:)
      accepted_used_op = create(:full_used_operator, clear:)
      declined_used_op = create(:full_used_operator, clear:)

      sign_in_as_verifier

      # Create verification
      visit clear_path(clear)

      within 'main' do
        click_link 'Verify'
      end

      expect(page).to have_content('Clear verification')
      click_link "View details of #{accepted_used_op.name}"
      expect_page_have_operator_details(accepted_used_op)
      click_button 'Verify operator'
      wait_for_turbo
      expect_operator_verification(accepted_used_op, 'Verified')

      click_link "View details of #{declined_used_op.name}"
      expect_page_have_operator_details(declined_used_op)
      click_button 'Decline operator'
      wait_for_turbo
      expect_operator_verification(declined_used_op, 'Declined')

      expect(page).to have_content('1-1')
      expect(page).to have_button('Accept', disabled: true)

      click_button 'Decline'

      expect(page).to have_content('All done! No more clears to verify!')
      expect(clear.verification).to be_declined
      expect(accepted_used_op).to be_verification_accepted
      expect(declined_used_op).to be_verification_declined

      # Edit verification
      visit clear_path(clear)
      expect(page).to have_content('Declined')

      click_link 'Edit verification'
      expect(page).to have_content('Clear verification')
      expect(page).to have_content('Declined')
      expect_operator_verification(accepted_used_op, 'Verified')
      expect_operator_verification(declined_used_op, 'Declined')
      expect(page).to have_button('Accept', disabled: true)

      click_link "View details of #{declined_used_op.name}"
      click_button 'Verify operator'
      expect_operator_verification(declined_used_op, 'Verified')
      click_button 'Accept'

      expect(page).to have_content('Verification was successfully updated!')
      expect(page).to have_current_path(clear_path(clear))
      expect(page).to have_content('Verified')
    end

    it 'can quickly verify clears' do
      reported_verified_clear = create(:clear, :verified)
      create(:report, clear: reported_verified_clear)
      clear = create(:clear)
      verifier = reported_verified_clear.verifier

      sign_in(verifier)

      click_link 'Verify'

      expect(page).to have_content('Clear verification')
      expect(page).to have_content(clear.stage.code)

      click_link 'Prev'

      expect(page).to have_content('Clear verification')
      expect(page).to have_content(reported_verified_clear.stage.code)
      expect(page).to have_css("svg[alt='Flagged for review']")
      expect(page).to have_content('Verified')

      click_link 'Next'

      expect(page).to have_content(clear.stage.code)
      click_link 'Go to clear'

      expect(page).to have_current_path(clear_path(clear))
    end
  end
end
