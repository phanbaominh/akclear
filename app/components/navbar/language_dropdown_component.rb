# frozen_string_literal: true

class Navbar::LanguageDropdownComponent < ApplicationComponent
  LOCALE_TO_NAME = {
    en: 'English',
    jp: 'Japanese'
  }.freeze

  def post_initialize(flatten: false)
    @flatten = flatten
  end

  def name(locale)
    LOCALE_TO_NAME[locale]
  end

  def current_locale
    I18n.locale
  end

  def locale_options
    available_locales.excluding(current_locale)
  end

  def icon(locale)
    "images/flag-#{locale}.svg"
  end

  private

  def available_locales
    I18n.available_locales
  end
end
