# frozen_string_literal: true

class Risk < ApplicationRecord
  belongs_to :contigency_contract

  def conflicted_risks
    @conflicted_risks ||= Risks::ConflictedRisks.new(self)
  end
end
