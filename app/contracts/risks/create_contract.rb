# frozen_string_literal: true

module Risks
  class CreateContract < ApplicationContract
    params do
      required(:description).filled(:string)
      required(:icon).filled(type?: File)
      required(:level).filled(:integer, gteq?: 1, lteq?: 3)
      required(:contigency_contract_id).filled(:integer)
    end

    rule(:contigency_contract_id) do |context:|
      context[:contigency_contract] = ContigencyContract.find_by(id: value)
      key.failure(:not_found) unless context[:contigency_contract]
    end
  end
end
