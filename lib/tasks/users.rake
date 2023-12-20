namespace :users do
  task create_admin: :environment do
    # TODO: TEMP SOLUTION DUE TO WITHOUT SHELL ACCESS IN PROD
    return if ENV['ADMIN_EMAIL'].blank?

    User.create_with(password: ENV.fetch('ADMIN_PASSWORD', nil), role: :admin,
                     username: 'admin').find_or_create_by(email: ENV.fetch('ADMIN_EMAIL', nil))
  end
end
