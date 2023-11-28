# frozen_string_literal: true

class Primer::TabsComponent < ApplicationComponent
  include Pagy::Frontend
  attr_reader :tab_names, :hidden_class

  renders_many :tabs

  def post_initialize(tab_names:, hidden_class: 'hidden')
    @tab_names = tab_names
    @hidden_class = hidden_class
  end
end
