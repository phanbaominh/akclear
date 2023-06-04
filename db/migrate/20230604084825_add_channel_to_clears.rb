class AddChannelToClears < ActiveRecord::Migration[7.0]
  def change
    add_reference :clears, :channel, foreign_key: true
  end
end
