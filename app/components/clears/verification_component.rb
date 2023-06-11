# frozen_string_literal: true

class Clears::VerificationComponent < ApplicationComponent
  attr_reader :clear, :verification

  def initialize(clear:)
    @clear = clear
    @verification = clear.verification
  end 
end
