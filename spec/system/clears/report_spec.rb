require 'system_spec_helper'

describe 'Reports clear', :js do
  let_it_be(:clear) { create(:clear) }

  context 'when user is not signed in' do
    it 'cannot report a clear' do
      visit clear_path(clear)

      click_button 'Flag for review'

      expect(page).to have_current_path(sign_in_path)
      expect(page).to have_content('You need to sign in or sign up before continuing')
    end
  end

  describe 'when user is signed in' do
    it 'can report a clear' do
      user = sign_in

      visit clear_path(clear)

      click_button 'Flag for review'
      expect(page).to have_content('Thank you for flagging this clear. We will review it shortly.')
      expect(clear.reported_by?(user)).to be_truthy

      click_button 'Unflag'

      expect(page).to have_content('You have unflagged this clear.')
      expect(clear.reported_by?(user)).to be_falsy
    end
  end
end
