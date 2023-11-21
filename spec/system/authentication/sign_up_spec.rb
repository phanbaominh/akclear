require 'system_spec_helper'

RSpec.describe 'Signing up' do
  context 'when filling in correct information' do
    it 'redirects to home and show notification' do
      visit sign_up_path
      # click_link 'Sign in'
      # click_link 'Sign up'
      # if uncomment above will be flaky for some reason, sometimes email is not filled in, maybe turbo related?
      fill_in 'Email', with: 'test@mail.com'
      fill_in 'Password', with: 'gamegame1234'
      fill_in 'Password confirmation', with: 'gamegame1234'
      click_button 'Sign up'
      expect(page).to have_current_path(root_path)
      expect(page).to have_content('Welcome! You have signed up successfully')
      expect(User.first.email).to eq('test@mail.com')
    end
  end
end
