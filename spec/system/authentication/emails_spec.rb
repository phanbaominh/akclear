require 'system_spec_helper'

describe 'Authentication emails' do
  describe 'Verifying email' do
    it 'shows notification' do
      user = create(:user, verified: false)
      sid = user.generate_token_for(:email_verification)

      visit identity_email_verification_path(sid:)

      expect(page).to have_current_path(root_path)
      expect(page).to have_content('Thank you for verifying your email address')
      expect(user.reload.verified).to be_truthy
    end
  end

  describe 'Changing email page' do
    before do
      sign_in(user)

      find('details', text: 'Profile').click
      within('details') do
        click_link 'Change email address'
      end
    end

    context 'when user is not verified yet' do
      let_it_be(:user) { create(:user) }

      it 'allows users to re-send verification email' do
        mailer = instance_double(UserMailer, email_verification: double(deliver_later: true))
        allow(UserMailer).to receive(:with).and_return(mailer)

        expect(page).to have_content(
          'We sent a verification email to the address below. ' \
          "Check that email and follow those instructions to confirm it's your email address."
        )

        click_button 'Re-send verification email'

        expect(page).to have_current_path(root_path)
        expect(page).to have_content('We sent a verification email to your email address')
        expect(UserMailer).to have_received(:with).with(user:)
        expect(mailer).to have_received(:email_verification)
      end
    end

    context 'when user is verified' do
      let_it_be(:user) { create(:user, verified: true) }

      it 'allows users to change email' do
        expect(page).to have_field('New email', with: user.email)

        fill_in 'New email', with: 'new@mail.com'
        fill_in 'Current password', with: user.password
        click_button 'Change email address'

        expect(page).to have_current_path(root_path)
        expect(page).to have_content('Your email has been changed')
        expect(user.reload.email).to eq('new@mail.com')
      end
    end
  end
end
