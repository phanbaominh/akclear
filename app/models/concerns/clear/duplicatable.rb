module Clear::Duplicatable
  DUPLICATION_LIMIT = 5

  def duplicate_for_stage_ids(stage_ids)
    stage_ids
      .uniq
      .reject { |si| si == stage_id }
      .first(Clear::Duplicatable::DUPLICATION_LIMIT)
      .compact.map do |stage_id|
      duplicate_clear = dup
      dup_used_operators = duplicate_squad
      # to pass uniqueness validation, need to reassign stage_ids
      duplicate_clear.stage_ids = [stage_id]
      duplicate_clear.stage_id = stage_id
      duplicate_clear.used_operators = dup_used_operators
      duplicate_clear.channel = channel
      duplicate_clear.job_id = nil
      duplicate_clear
    end.each(&:save)
  end

  def duplicate_squad
    loaded_used_operators = used_operators.includes(:operator)
    loaded_used_operators.map do |used_operator|
      dup_used_operator = used_operator.dup
      dup_used_operator.operator = used_operator.operator
      dup_used_operator
    end
  end
end
