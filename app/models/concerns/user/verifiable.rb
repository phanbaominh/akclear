module User::Verifiable
  def verifier?
    false
  end

  def verify(clear)
    clear.create_verification(verifier: self) unless clear.verified?
  end

  def unverify(clear)
    clear.verification&.destroy if clear.verified?
  end
end
