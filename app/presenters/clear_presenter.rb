class ClearPresenter < ApplicationPresenter
  def player_name
    object.channel&.title || I18n.t(:anonymous)
  end

  def verification_text
    return nil unless verification

    if verification.accepted?
      I18n.t(:verified)
    else
      I18n.t(:rejected)
    end
  end

  def verification_color(prefix, suffix = nil)
    # for tailwind purge: badge-success badge-error text-success-content text-error-content
    return nil unless verification

    if verification.accepted?
      "#{prefix}-success"
    else
      "#{prefix}-error"
    end + (suffix ? "-#{suffix}" : '')
  end

  private

  def verification
    object.verification
  end
end
