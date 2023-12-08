# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :reporter, class_name: 'User', foreign_key: :user_id, inverse_of: :reports
  belongs_to :clear
end
