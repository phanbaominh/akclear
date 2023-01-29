module Clear::Squadable
  extend ActiveSupport::Concern

  included do
    has_many :used_operators, dependent: :destroy
  end
end
