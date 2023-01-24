class Clear < ApplicationRecord
  belongs_to :uploader
  belongs_to :stage
  belongs_to :player
end
