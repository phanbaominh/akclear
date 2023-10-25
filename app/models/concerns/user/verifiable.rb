module User::Verifiable
  def verifier?
    true
  end

  def verify(clear, params)
    if clear.verified?
      clear.verification.update(verifier: self, **params)
    else
      clear.create_verification(verifier: self, **params)
    end
  end

  def unverify(clear)
    clear.verification&.destroy if clear.verified?
  end
end
