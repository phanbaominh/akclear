require 'system_spec_helper'

RSpec.describe 'Sessions' do
  describe 'Signing in' do
    context 'when enter correct information' do
      it 'shows success notification' do
        sign_in
        expect(page).to have_content('Signed in successfully')
      end
    end

    context 'when enter incorrect information' do
      it 'shows errors' do
        sign_in(password: 'wrong')

        expect(page).to have_content('That email or password is incorrect')
      end
    end
  end

  describe 'Signing out' do
    it 'redirects to sign in page' do
      sign_in

      find('details', text: 'Profile').click
      within('details') do
        click_button 'Log out'
      end
      expect(page).to have_current_path(sign_in_path)
    end
  end
end
