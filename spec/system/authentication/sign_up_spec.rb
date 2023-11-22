require 'system_spec_helper'

RSpec.describe 'Signing up' do
  context 'when filling in correct information' do
    it 'sends mail, redirects to home and show notification' do
      mailer = instance_double(UserMailer, email_verification: double(deliver_later: true))
      allow(UserMailer).to receive(:with).and_return(mailer)

      visit sign_up_path
      # click_link 'Sign in'
      # click_link 'Sign up'
      # if uncomment above will be flaky for some reason, sometimes email is not filled in, maybe turbo related?
      # possibly, the email field of sign in page is filled in before turbo drive replace with sign up page
      # need to wait for turbo load maybe?
      fill_in 'Email', with: 'test@mail.com'
      fill_in 'Password', with: 'gamegame1234'
      fill_in 'Password confirmation', with: 'gamegame1234'
      click_button 'Sign up'

      expect(page).to have_current_path(root_path)
      expect(page).to have_content('Welcome! You have signed up successfully')

      user = User.first
      expect(user.email).to eq('test@mail.com')
      expect(UserMailer).to have_received(:with).with(user:)
      expect(mailer).to have_received(:email_verification)
    end
  end
end
