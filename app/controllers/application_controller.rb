# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from Pundit::NotAuthorizedError do
    render file: Rails.root.join('public/404.html'), layout: false, status: :not_found
  end
end
