# frozen_string_literal: true

class Clears::VerificationComponent < ApplicationComponent
  attr_reader :clear, :verification

  def initialize(clear:)
    @clear = clear
    @verification = clear.verification
  end

  def can_create_verification?
    result = can?(:create, clear.build_verification) # due to ability check definition
    clear.verification = nil # make sure it doesn't affect other components
    result
  end
end
