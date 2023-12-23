require 'system_spec_helper'

RSpec.describe 'Authorization' do
  let(:self_path_dict) do
    {
      edit_self_clear_page: edit_clear_path(self_clear),
      edit_rejected_self_clear_page: edit_clear_path(rejected_self_clear),
      edit_self_verification_page: edit_clear_verification_path(self_verified_clear),
      edit_self_page: edit_admin_user_path(user)
    }
  end
  let(:non_self_paths_dict) do
    {
      clears_page: clears_path,
      clear_page: clear_path(clear),
      channels_page: channels_path,
      channel_page: channel_path(channel),
      new_clear_page: new_clear_path,
      edit_clear_page: edit_clear_path(clear),
      new_verification_page: new_clear_verification_path(clear),
      new_verification_with_no_channel_page: new_clear_verification_path(clear_with_no_channel),
      edit_verification_page: edit_clear_verification_path(verified_clear),
      new_channel_page: new_channel_path,
      admin_page: admin_path,
      new_video_imports_page: new_admin_videos_import_path,
      clear_jobs_path: admin_clear_jobs_path,
      new_clear_job_path: new_admin_clear_job_path,
      edit_clear_job_path: edit_admin_clear_job_path(clear_job),
      users_page: admin_users_path,
      edit_user_page: edit_admin_user_path(any_user)
    }
  end

  shared_examples 'has access to pages' do
    let(:clear) { create(:clear) }
    let(:clear_with_no_channel) { create(:clear, channel: nil) }
    let(:channel) { create(:channel) }
    let(:self_clear) { create(:clear, submitter: user) }
    let(:rejected_self_clear) { create(:clear, :rejected, submitter: user) }
    let(:verified_clear) { create(:clear, :verified) }
    let(:self_verification) { create(:verification, verifier: user) }
    let(:self_verified_clear) { self_verification.clear }
    let(:clear_job) { create(:extract_clear_data_from_video_job) }
    let(:any_user) { create(:user) }

    it 'can access pages' do
      sign_in user if user

      paths_dict.each do |key, path|
        next if key.to_s.include?('self') && user.blank?

        accessible = accessible_paths.include?(key)

        visit path

        if accessible
          expect(page).to have_current_path(path), "expected current path to be #{path} but was #{page.current_path}"
          expect(page).not_to have_current_path(user ? root_path : sign_in_path)
        else
          expect(page).to have_current_path(user ? root_path : sign_in_path),
                          "expected current path to be #{user ? root_path : sign_in_path} but was #{page.current_path}"
        end
      end
    end
  end

  context 'when user is guest' do
    let_it_be(:user) { nil }
    let(:paths_dict) { non_self_paths_dict }

    let(:accessible_paths) do
      %i[clears_page clear_page channels_page channel_page]
    end

    it_behaves_like 'has access to pages'
  end

  context 'when user is normal' do
    let_it_be(:user) { create(:user) }
    let(:paths_dict) { non_self_paths_dict.merge(self_path_dict) }

    let(:accessible_paths) do
      %i[clears_page clear_page channels_page channel_page
         new_clear_page edit_rejected_self_clear_page]
    end

    it_behaves_like 'has access to pages'
  end

  context 'when user is verifier' do
    let_it_be(:user) { create(:verifier) }
    let(:paths_dict) { non_self_paths_dict.merge(self_path_dict) }

    let(:accessible_paths) do
      %i[clears_page clear_page channels_page channel_page
         new_clear_page edit_rejected_self_clear_page
         new_verification_page edit_self_verification_page new_channel_page]
    end

    it_behaves_like 'has access to pages'
  end

  context 'when user is admin' do
    let_it_be(:user) { create(:admin) }
    let(:paths_dict) { non_self_paths_dict.merge(self_path_dict) }

    let(:accessible_paths) do
      paths_dict.keys - %i[edit_self_page]
    end

    it_behaves_like 'has access to pages'
  end
end
