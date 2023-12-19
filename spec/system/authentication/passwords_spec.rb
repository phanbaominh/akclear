require 'system_spec_helper'

describe 'Passwords' do
  describe 'Changing password' do
    let_it_be(:user, reload: true) { create(:user) }

    before do
      sign_in(user)

      find('details', text: 'Profile').click
      within('details') do
        click_link 'Change password'
      end
    end

    context 'when enter correct information' do
      it 'shows notification' do
        fill_in 'Current password', with: 'Thisisavalidpassword1@'
        fill_in 'Password', with: 'newpassword1234'
        fill_in 'Password confirmation', with: 'newpassword1234'
        click_button 'Change password'

        expect(page).to have_content('Your password has been changed')
        expect(page).to have_current_path(root_path)
        expect(User.authenticate_by(email: user.email, password: 'newpassword1234')).to be_present
      end
    end

    context 'when enter incorrect information' do
      it 'shows errors' do
        fill_in 'Current password', with: 'a'
        click_button 'Change password'

        expect(find_field('Current password')).to have_sibling('div.simple_form__label_wrapper', text: 'is invalid')
      end
    end
  end

  describe 'Resetting password' do
    let_it_be(:user, reload: true) { create(:user) }

    describe 'Requesting password reset' do
      before do
        visit sign_in_path
        click_link 'Forgot your password?'
      end

      context 'when user is not verified yet' do
        it 'shows notification' do
          fill_in 'Email', with: user.email
          click_button 'Send password reset email'

          expect(page).to have_content("You can't reset your password until you verify your email")
        end
      end

      context 'when enter correct information' do
        it 'sends mails and shows notification' do
          mailer = instance_double(UserMailer, password_reset: double(deliver_later: true))
          allow(UserMailer).to receive(:with).and_return(mailer)
          user.update(verified: true)

          fill_in 'Email', with: user.email
          click_button 'Send password reset email'

          expect(page).to have_content('Check your email for reset instructions')
          expect(page).to have_current_path(sign_in_path)
          expect(UserMailer).to have_received(:with).with(user:)
          expect(mailer).to have_received(:password_reset)
        end
      end

      context 'when enter incorrect information' do
        it 'shows errors' do
          fill_in 'Email', with: 'wrong@mail.com'
          click_button 'Send password reset email'

          expect(page).to have_content("You can't reset your password until you verify your email")
        end
      end
    end

    describe 'Resetting password from link' do
      before do
        sid = user.generate_token_for(:password_reset)
        visit edit_identity_password_reset_path(sid:)
      end

      context 'when enter incorrect information' do
        it 'shows errors' do
          fill_in 'Password', with: 'a'
          click_button 'Save changes'

          expect(find_field('Password')).to have_sibling('div.simple_form__label_wrapper',
                                                         text: 'is too short (minimum is 12 characters)')
        end
      end

      context 'when enter correct information' do
        it 'shows notification and requires sign in again' do
          fill_in 'Password', with: 'newpassword1234'
          fill_in 'Password confirmation', with: 'newpassword1234'
          click_button 'Save changes'

          expect(page).to have_content('Your password was reset successfully. Please sign in')
          expect(page).to have_current_path(sign_in_path)

          sign_in(user, password: 'newpassword1234')
          expect(page).to have_content('Signed in successfully')
        end
      end
    end
  end
end
