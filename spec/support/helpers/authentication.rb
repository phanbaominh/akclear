module Helpers
  module Authentication
    def sign_in(user = create(:user), password: 'Thisisavalidpassword1@', expect: true)
      visit sign_in_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: password
      click_button 'Sign in'
      expect(page).to have_content('Signed in successfully') if expect
      user
    end

    def sign_in_as_admin
      sign_in(create(:user, :admin))
    end
  end
end
