require 'system_spec_helper'

describe 'Channels', :js do
  context 'when normal user' do
    before { sign_in }

    it 'does not show the new channel button' do
      visit channels_path

      expect(page).not_to have_link('New channel')
    end

    it 'does not show the delete channel button' do
      create(:channel, title: 'Test Channel')

      visit channels_path

      expect(page).not_to have_content('Clear languages')

      click_link 'Test Channel'

      expect(page).not_to have_button('Delete')
    end
  end

  context 'when verifier' do
    before { sign_in_as_verifier }

    it 'shows the new channel button' do
      visit channels_path

      expect(page).to have_link('New channel')
    end

    it 'shows the delete channel button' do
      create(:channel, title: 'Test Channel')

      visit channels_path

      expect(page).to have_content('Clear languages')
      click_link 'Test Channel'

      expect(page).not_to have_button('Delete')
    end
  end
end
