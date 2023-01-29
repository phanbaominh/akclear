# frozen_string_literal: true

module Clear::HardTaggable
  include Dry::Monads::Do.for(:add_hard_tags, :remove_hard_tags) # use for all methods make factory bot fail
  extend ActiveSupport::Concern

  included do
    acts_as_taggable_on :hard_tags
  end

  def add_hard_tags(hard_tags)
    new_hard_tag_list = yield hard_tag_list_wrapper.add_tags(hard_tags)
    self.hard_tag_list = new_hard_tag_list
    Success()
  end

  def remove_hard_tags(hard_tags)
    new_hard_tag_list = yield hard_tag_list_wrapper.remove_tags(hard_tags)
    self.hard_tag_list = new_hard_tag_list
    Success()
  end

  private

  def hard_tag_list_wrapper
    Clear::HardTagList.new(hard_tag_list)
  end
end
