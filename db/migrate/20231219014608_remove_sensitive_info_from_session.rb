class RemoveSensitiveInfoFromSession < ActiveRecord::Migration[7.1]
  def change
    change_table :sessions, bulk: true do |t|
      t.remove :ip_address, type: :string
      t.remove :user_agent, type: :string
    end
  end
end
