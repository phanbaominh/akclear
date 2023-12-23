# frozen_string_literal: true

class NavbarComponent < ApplicationComponent
  def links_component
    admin_pages? ? Admin::Navbar::LinksComponent : Navbar::LinksComponent
  end
end
