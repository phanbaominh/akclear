class StagePresenter < ApplicationPresenter
  def code_with_mods
    if object.annihilation?
      object.stageable.label
    else
      [object.stageable.label + ':', object.code, object.challenge_mode? ? 'CM' : nil,
       object.environment].compact.join(' ')
    end
  end

  def number
    object.code.split('-').last.to_i
  end
end
