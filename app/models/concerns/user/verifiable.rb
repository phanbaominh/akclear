module User::Verifiable
  extend ActiveSupport::Concern

  def verifier?
    true
  end

  # Move this to Clear::Verifiable
  def verify(clear, params)
    if clear.verified?
      params[:used_operator_verifications_attributes].each do |_, used_operator_verification|
        used_operator_verification[:id] = clear.verification.used_operator_verifications.find do |v|
          v.used_operator_id == used_operator_verification[:used_operator_id].to_i
        end&.id
      end
      clear.verification.update(verifier: self, **params)
    else
      clear.create_verification(verifier: self, **params)
    end
    clear.reports.destroy_all
  end

  def unverify(clear)
    clear.verification&.destroy if clear.verified?
  end

  def rejected_clears
    Clear.submitted_by(self).joins(:verification).merge(Verification.rejected)
  end

  def has_rejected_clears?
    rejected_clears.exists?
  end
end
