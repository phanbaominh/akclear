require 'system_spec_helper'

RSpec.describe 'Signing in' do
  it 'shows notification' do
    sign_in
    expect(page).to have_content('Signed in successfully')
  end
end
