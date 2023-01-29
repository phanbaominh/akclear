# frozen_string_literal: true

class Clear::HardTagList
  include Dry::Monads[:result, :do]
  VALID_TAGS = [
    LOW_END = 'Low-end',
    HIGH_END = 'High-end',
    NO_6_STARS = 'No-6-stars',
    ONLY_3_STARS = 'Only-3-stars'
  ].freeze
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def add_tags(tags)
    tags = tags.uniq
    valid_tags = yield validate_tags(tags)

    Success((value + valid_tags).uniq)
  end

  def remove_tags(tags)
    Success((value - tags).uniq)
  end

  private

  def validate_tags(tags)
    if (invalid_tags = tags - VALID_TAGS).present?
      Failure("Not valid tags: #{invalid_tags.join(', ')} ")
    else
      Success(tags)
    end
  end
end
