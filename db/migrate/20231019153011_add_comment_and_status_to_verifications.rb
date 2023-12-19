class AddCommentAndStatusToVerifications < ActiveRecord::Migration[7.0]
  def change
    change_table :verifications, bulk: true do |t|
      t.column :status, :integer
      t.column :comment, :text, limit: 1000
    end
  end
end
