class Verification < ApplicationRecord
  belongs_to :verifier, class_name: 'User'
  belongs_to :clear
end
