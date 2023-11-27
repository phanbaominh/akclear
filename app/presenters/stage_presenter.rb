class StagePresenter < ApplicationPresenter
  def code_with_mods
    [object.code, object.challenge_mode? ? 'CM' : nil, object.environment].compact.join(' ')
  end

  def number
    object.code.split('-').last.to_i
  end
end
