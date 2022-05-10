RailsAdmin.config do |config|
  config.asset_source = :webpacker

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  ## == CancanCan ==
  # config.authorize_with :cancancan

  # == Pundit ==
  config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/railsadminteam/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard do # mandatory
      authorization_key :admin
    end
    index { authorization_key :admin }
    new { authorization_key :admin }
    export { authorization_key :admin }
    bulk_delete { authorization_key :admin }
    show { authorization_key :admin }
    edit { authorization_key :admin }
    delete { authorization_key :admin }
    show_in_app { authorization_key :admin }

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.parent_controller = '::ApplicationController'
end
