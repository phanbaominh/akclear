# frozen_string_literal: true

module Risks
  class CreateContract < ApplicationContract
    params do
      required(:description).filled(:string)
      required(:icon).filled(type?: File)
      required(:level).filled(:integer, gteq?: 1, lteq?: 3)
      required(:contingency_contract_id).filled(:integer)
    end

    rule(:contingency_contract_id) do |context:|
      context[:contingency_contract] = ContingencyContract.find_by(id: value)
      key.failure(:not_found) unless context[:contingency_contract]
    end
  end
end
