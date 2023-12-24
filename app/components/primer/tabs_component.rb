# frozen_string_literal: true

class Primer::TabsComponent < ApplicationComponent
  include Pagy::Frontend
  attr_reader :tab_names, :hidden_class, :tab_header_class, :default_tab_name

  renders_one :content_with_tabs

  def post_initialize(tab_names:, hidden_class: 'hidden', tab_header_class: '', default_tab_name: nil)
    @tab_names = tab_names
    @hidden_class = hidden_class
    @tab_header_class = tab_header_class
    @default_tab_name = default_tab_name || tab_names.first
  end
end
